mutable struct Cell 
    value::Int
    superpositions::Array{Int}

    Cell() = new(0, [1,2,3,4,5,6,7,8,9])
end

function collapse(cell, value)
    filter!(x->x!=value, cell.superpositions)
    if length(cell.superpositions) == 1
        value = cell.superpositions[1]
        pop!(cell.superpositions)
    end
end

struct Position 
    i::Int
    j::Int
end

function get_square(grid, i, j)
    ranges = [1:3, 4:6, 7:9]
    width_range::Int = ceil((j/9) * 3)
    height_range::Int = ceil((i/9) * 3)

    x = ranges[width_range]
    y = ranges[height_range]

    return grid[y, x]
end

struct Board 
    grid

    function Board()
        ng = Array{Cell}(undef, 9, 9)

        for i in eachindex(collect(eachrow(ng)))
            for j in eachindex(collect(eachcol(ng)))
                ng[i, j] = Cell()
            end
        end
        new(ng)
    end
end

function place_on_board(grid, value, pos)
    row = collect(eachrow(grid.grid))[pos.i]
    col = collect(eachcol(grid.grid))[pos.j]
    sq = get_square(grid.grid, pos.i, pos.j)
    collapse(grid.grid[pos.i, pos.j], value)

    for cell in row 
        collapse(cell, value)
    end

    for cell in col 
        collapse(cell, value)
    end

    for cell in sq 
        collapse(cell, value)
    end
    grid.grid[pos.i, pos.j].value = value
end

function initialize_board()
    numbers = [
        0 7 0 0 2 0 0 4 6;
        0 6 0 0 0 0 8 9 0;
        2 0 0 8 0 0 7 1 5;
        0 8 4 0 9 7 0 0 0;
        7 1 0 0 0 0 0 5 9;
        0 0 0 1 3 0 4 8 0;
        6 9 7 0 0 2 0 0 8;
        0 5 8 0 0 0 0 6 0;
        4 3 0 0 8 0 0 7 0
    ]
    rows = eachindex(collect(eachrow(numbers)))
    cols = eachindex(collect(eachcol(numbers)))
    board = Board()

    # the cells of the board must all  be initialized before the place_on_board() function can be called
    for i in rows 
        for j in cols 
            place_on_board(board, numbers[i, j], Position(i, j))
        end
    end
    return board
end

function solve_board(board)
    rows = eachindex(collect(eachrow(board.grid)))
    cols = eachindex(collect(eachcol(board.grid)))

    # first find all solved squares
    i = 1
    j = 0
    trials = 0
    while true
        j+=1
        cell = board.grid[i, j]
        if cell.value == 0
            println(length(cell.superpositions))
            if length(cell.superpositions) == 1
                println("GETTING HERE")
                place_on_board(board, cell.superpositions[1], Position(i, j))
            end
        end


        if j == 9
            i += 1
            j = 0
        end

        if j == 9 && i == 9
            i = 1
            j = 0
        end

        if trials >= 150
            break
        else
            trials+=1
        end
    end
end

function main()
    board = initialize_board()
    solve_board(board)
    #display_board(board)
end

function display_board(board)
    numrep::Matrix{Int} = zeros(9, 9)
    for i in eachindex(collect(eachrow(board.grid)))
        for j in eachindex(collect(eachcol(board.grid)))
            numrep[i, j] = board.grid[i, j].value
        end
    end

    display(numrep)
end

main()