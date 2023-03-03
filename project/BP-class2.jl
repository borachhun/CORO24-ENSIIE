using JuMP, LinearAlgebra, GLPK, SparseArrays


function solve_aux_prob(
    dual_demand_satisfaction,
    total_length,
    lengths,
    demand,
    c,
)
    reduced_costs = dual_demand_satisfaction
    n = length(reduced_costs)

    # The current pricing model.
    AP = Model(GLPK.Optimizer)
    set_silent(AP) #doesn't show the log
    @variable(AP, x[1:n] >= 0, Int)
    @constraint(AP, sum(x .* lengths) <= total_length)
    @objective(AP, Max, sum(x .* reduced_costs))
    print(AP)
    optimize!(AP)

    new_pattern = round.(Int, value.(x))
    net_cost = 1 - sum(new_pattern .* dual_demand_satisfaction)
    # If the net cost of this new pattern is nonnegative, no more patterns to add. 
    if  net_cost >= 0  
        return nothing
    else 
        return new_pattern
    end
end

function ex_cutting_stock()
    max_gen_cols= 1000
    c = 1

    io = open("CORO24-ENSIIE/project/data.txt", "r")
    total_length = parse.(Int64, readline(io))
    lengths = parse.(Int64, split(readline(io), ","))
    demand = parse.(Int64, split(readline(io), ","))
    close(io)

    # total_length = 100
    # lengths = [22,42,52,53,78]
    # demand = [45,38,25,11,12]

    n = length(lengths)
    ncols = length(lengths)

    # Initial set of patterns (stored in a sparse matrix: a pattern won't
    # include many different cuts).
    patterns = SparseArrays.spzeros(UInt16, n, ncols)
    for i in 1:n
        patterns[i, i] =
            min(floor(Int, total_length / lengths[i]), round(Int, demand[i]))
    end

    RMP = Model(GLPK.Optimizer)
    set_silent(RMP) 
    @variable(RMP, lambda[1:ncols] >= 0)
    @objective(
        RMP,
        Min,
        sum(c * lambda[p] for p in 1:ncols)
    )
    @constraint(
        RMP,
        demand_satisfaction[j = 1:n],
        sum(patterns[j,p] * lambda[p] for p in 1:ncols) >= demand[j]
    )
    print(RMP)
    # First solve of the master problem.
    optimize!(RMP)

    # Then, generate new patterns, based on the dual information.
    while ncols - n <= max_gen_cols ## Generate at most max_gen_cols columns.
        if !has_duals(RMP)
            break
        end
        new_pattern = solve_aux_prob(
            dual.(demand_satisfaction),
            total_length,
            lengths,
            demand,
            c,
        )
        # If there is no new pattern to add to the formulation: done!
        if new_pattern === nothing
            break
        end
        # Otherwise, add the new pattern to the master problem, recompute the
        # duals, and compute one more time the pricing problem.
        ncols += 1
        patterns = hcat(patterns, new_pattern) #add a new pattern to the set patterns 
        # One new variable.
        push!(lambda, @variable(RMP, base_name = "lambda", lower_bound = 0))
        # Update the objective function.
        set_objective_coefficient(
            RMP,
            lambda[ncols],
            c,
        )
        # Update the constraint number j if the new pattern impacts this production.
        for j in 1:n
            if new_pattern[j] > 0
                set_normalized_coefficient(
                    demand_satisfaction[j],
                    lambda[ncols],
                    new_pattern[j],
                )
            end
        end
        # Solve the new master problem to update the dual variables.
        optimize!(RMP)
    end
    # Impose the master variables to be integer and solve.
    set_integer.(lambda)
    optimize!(RMP)
    println("Final solution:")
    for i in 1:ncols
        if value(lambda[i]) > 0.5
            println("$(round(Int, value(lambda[i]))) units of pattern $(i)")
            print_one_pattern(patterns, lengths, i)
        end
    end
    return
end

function print_one_pattern(patterns, lengths, col)
    n = length(lengths)
    
    print("[ ")
    for i in 1:n
        for _ in 1:patterns[i,col]
            print("$(lengths[i]) ")
        end
    end
    print("]\n\n")
end

ex_cutting_stock()