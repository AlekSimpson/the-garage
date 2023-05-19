struct Cell 
    value::Int
    superpositions::Array{Int}

    Cell() = new(0, [1,2,3,4,5,6,7,8,9])

    function collapse(value)
        filter!(x->x!=value, superpositions)
        if length(superpositions) == 1
            value = superpositions[1]
            pop!(superpositions)
        end
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
    grid::Array{Cell}(undef, 9, 9)
    
    Board() = new(Array{Cell}(undef, 9, 9))

    function place_on_board(value, pos)
        row = collect(eachrow(grid))[pos.i]
        col = collect(eachcol(grid))[pos.j]
        sq = get_square(grid, pos.i, pos.j)
        grid[pos.i, pos.j].collapse(value)

        for cell in row 
            cell.collapse(value)
        end

        for cell in col 
            cell.collapse(value)
        end

        for cell in sq 
            cell.collapse(value)
        end
    end
end

#function does_collide(grid, num, i, j)
#    square = get_square(grid, i, j)
#
#    rows = collect(eachrow(grid))
#    cols = collect(eachcol(grid))
#
#    return (num in rows[i]) || (num in cols[j]) || (num in square)
#end

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

    for i in rows
        for j in cols 
            #board.place_on_board(num, Position(i, j))
            board.grid[i, j] = Cell()
        end
    end

    # the cells of the board must all  be initialized before the place_on_board() function can be called
    for i in rows 
        for j in cols 
            board.place_on_board(numbers[i, j], Position(i, j))
        end
    end
end

function main()
    board = initialize_board()
end

main()