using Random

function rand_from_pool(not_visited)
    shuffled = shuffle(not_visited)
    return shuffled[1]
end

function pop_pool(not_visited, element)
    filter!(x->x!=element, not_visited)
end

function does_collide(grid, num, i, j)
    square = get_square(grid, i, j)

    rows = collect(eachrow(grid))
    cols = collect(eachcol(grid))

    return (num in rows[i]) || (num in cols[j]) || (num in square)
end

function get_square(grid, i, j)
    ranges = [1:3, 4:6, 7:9]
    width_range::Int = ceil((j/9) * 3)
    height_range::Int = ceil((i/9) * 3)

    x = ranges[width_range]
    y = ranges[height_range]

    return grid[y, x]
end

function backtrack(grid, not_visited, i, j)
    sqr = get_square(grid, i, j)
    targeted_value = 0
    targeted_col = 1
    for num in not_visited
        if !(num in sqr)
            targeted_value = num
            break
        end
        targeted_col +=1
    end
    col = collect(eachcol(grid))[targeted_col]

    grid[i, j] = targeted_value

    for idx in eachindex(col) 
        curr_val = col[idx]
        if !does_collide(grid, targeted_value, targeted_col, idx) && !does_collide(grid, curr_val, targeted_col, i)
            grid[targeted_col, idx] = targeted_value
            grid[targeted_col, i] = curr_val
            break
        end
    end
end

# nv_list- not_visited_list
function fix_zeros(grid, nv_list)
    rows = eachindex(collect(eachrow(grid)))
    cols = eachindex(collect(eachrow(grid)))

    for i in rows
        for j in cols 
            if grid[i, j] == 0
                backtrack(grid, nv_list[i], i, j)
            end
        end 
    end

    return grid
end

function gen_sudoku()
    grid::Matrix{Int} = zeros(9, 9)
    rows = eachindex(collect(eachrow(grid)))
    cols = eachindex(collect(eachrow(grid)))
    not_visited = []
    lefttover_not_visited = Any[]

    for i in rows 
        not_visited = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        for j in cols 
            shuffled_poss_values = rand_from_pool(not_visited)
            chosen_val = 0
            for num in shuffled_poss_values
                if !does_collide(grid, num, i, j)
                    chosen_val = num
                    break
                end
            end

            push!(lefttover_not_visited, not_visited)
            pop_pool(not_visited, chosen_val)
            grid[i, j] = chosen_val
        end
    end

    #grid = fix_zeros(grid, lefttover_not_visited)
    return grid
end

function main()
    grid = gen_sudoku()
    display(grid)
end

main()