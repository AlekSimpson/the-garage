#0,7,0,  0,2,0,   0,4,6
#0,6,0,  0,0,0,   8,9,0
#2,0,0,  8,0,0,   7,1,5
#     
#0,8,4,   0,9,7,  0,0,0
#7,1,0,   0,0,0,  0,5,9
#0,0,0,   1,3,0,  4,8,0
#     
#6,9,7,   0,0,2,  0,0,8
#0,5,8,   0,0,0,  0,6,0
#4,3,0,   0,8,0,  0,7,0

struct Cell
    num::Int
    superposition::Vector{Int}
    Cell(num, sp) = new(num, sp)
end

struct Square 
    slice::Matrix{Cell}
    i::Int
    j::Int

    Square(s, i, j) = new(s, i, j)
end

function collapse_cell(Cell, num)
    filter!(x->x!=num, Cell.superposition)
    if length(Cell.superposition) == 1
        Cell.num = Cell.superposition[1]
        pop!(Cell.superposition)
    end
end

function get_square(grid, i, j)
    ranges = [1:3, 4:6, 7:9]
    width_range::Int = ceil((j/9) * 3)
    height_range::Int = ceil((i/9) * 3)

    x = ranges[width_range]
    y = ranges[height_range]

    return Square(grid[y, x], i, j)
end

function does_collide(grid, num, i, j)
    square = get_square(grid, i, j)

    rows = collect(eachrow(grid))
    cols = collect(eachcol(grid))

    return (num in rows[i]) || (num in cols[j]) || (num in square)
end

board = [
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

#squares = [get_square(board, 1, 1), get_square(board, 4, 1), get_square(board, 7, 1),
#           get_square(board, 1, 4), get_square(board, 4, 4), get_square(board, 7, 4),
#           get_square(board, 1, 7), get_square(board, 4, 7), get_square(board, 7, 7)]

function get_from_lowest(lowest, index)
    if length(lowest) == 0
        return 1000
    else
        return lowest[index]
    end
end

function get_lowest_squares(squares)
    lowest_zeros = []
    lowest_count = []
    for square in squares 
        count = 0
        for num in square.slice
            if num == 0
                count+=1
            end
        end
        if count <= get_from_lowest(lowest_count, 1)
            append!(lowest_count, count)
            push!(lowest_zeros, square)
        end
    end
    return lowest_zeros
end

function find_missing_nums(square)
    missing_nums = []
    for i=1:9
        if !(i in square.slice)
            append!(missing_nums, i)
        end
    end
    return missing_nums
end

function collapse(row, col, sq, num)
    collapse_cell.(row, num)  
    collapse_cell.(col, num)
    collapse_cell.(sq, num)
end

function full_collapse(lowest_squares, board)
    #missing_nums = find_missing_nums(sq)
    rows = eachindex(collect(eachrow(board)))
    cols = eachindex(collect(eachcol(board)))

    # save board state and root pos 
    saved_board = deepcopy(board)
    root_pos = []
     
    for square in lowest_squares
        for cell in square.slice
            if cell.num == 0
                missing_nums = find_missing_nums(sq)
                if root_pos == []
                    root_pos = [cell.i, cell.j]
                end

                # try first missing num and collapse row, col and square
                # board[i, j].collapse(missing_nums[1])
                cell.num = missing_nums[1]
                collapse(rows[i], cols[j], sq, missing_nums[1])
                pop!(missing_nums)
            end
        end
    end
end

function remove_from_list(elements, list)
    for num in elements
        filter!(x->x!=num, list)
    end
end

function initialize_superpositions(board)
    superpositions = Array{Cell}(undef, 9, 9) 
    rows = collect(eachrow(board))
    cols = collect(eachcol(board))

    for i in eachindex(rows)
        for j in eachindex(cols)
            sp = [1, 2, 3, 4, 5, 6, 7, 8, 9]
            sq = get_square(board, i, j)

            remove_from_list(rows[i], sp)
            remove_from_list(cols[j], sp)
            remove_from_list(sq.slice, sp)
            new_cell = Cell(board[i, j], sp)
            superpositions[i, j] = new_cell
        end 
    end
    return superpositions
end

function solve(board)
    board = initialize_superpositions(board)
    lowest_squares = get_lowest_squares(squares)

    full_collapse(lowest_squares, board)
    return board
end

brd = solve(board)
display(brd)