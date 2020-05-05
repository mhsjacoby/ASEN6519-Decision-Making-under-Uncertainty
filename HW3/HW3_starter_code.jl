
using DMUStudent.HW3
using DMUStudent
using POMDPs
import POMDPModelTools: render
using POMDPPolicies
using MCTS



my_policy = FunctionPolicy(
    function pi(s) # this function represents a policy
        return A[s[2],s[1]]
    end
);

function solver_explore(d=30, n=65, c=50.0)
    println("n: $n, d: $d, c: $c")
    solver_n = MCTSSolver(
        n_iterations = n,         # default 100 - using 60
        max_time = 0.04,            # default Inf
        depth = d,                 # default 10 - using 10
        exploration_constant = c, # default 1.0 - using 50.0
        # estimate_value = RolloutEstimator(my_action_function)
        estimate_value = RolloutEstimator(my_policy),
        reuse_tree = true          # default false - using true
    );
    return solver_n
end

my_solver = solver_explore()
submit(my_solver, "hw3", "maja8167@colorado.edu", nickname="...")






### Some of the parameters explored
n_range = (5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70)
d_range = (5, 10, 15, 20, 30)
c_range = (1.0, 3.0, 5.0, 7.0, 10.0, 20.0, 30.0, 45.0, 50.0, 60.0)

for d in d_range
    my_solver = solver_explore(d)
    evaluate(my_solver, "hw3")
end

### Matrix for dertermining optimal actions
A = Array{Symbol}(undef, (100,100))
for i=1:10
    A[:,i] = fill(:right, (100,1))
end
for i=90:100
    A[:,i] = fill(:left, (100,1))
end
for i=11:89
    if i%20 >= 10
        A[:,i] = fill(:right, (100,1))
    elseif i%20 >= 1
        A[:,i] = fill(:left, (100,1))
    else
        for j=1:10
            A[j,i] = :up
        end
        for j=90:100
            A[j,i] = :down
        end
        for j=11:89
            if j%20 >= 10
                A[j,i] = :up
            elseif j%20 >= 1
                A[j,i] = :down
            else
                A[i,j] = :up
            end
        end
    end
end
#
##
# function solver_explore(n=20, d=30, c=5.0)
#     println("n: $n, d: $d, c: $c")
#     solver_n = DPWSolver(
#         n_iterations = n,         # default 100 - using 60
#         max_time = 0.04,            # default Inf
#         depth = d,                 # default 10 - using 10
#         exploration_constant = c, # default 1.0 - using 50.0
#         k_state=2.0,
#         k_action=2.0,
#         #estimate_value = RolloutEstimator(my_action_function),
#         next_action = my_action_function
#         # reuse_tree = true          # default false - using true
#     );
#     return solver_n
# end

function my_action_function(mdp, s, depth)
    return A[s[2],s[1]]
end


#
# function Q2_est(m, s, a)
#     s in keys(m.rewards) ? 100.0 : -6.0
# end
        # function Q_est(m, s, a)
        #     if s in keys(m.rewards)
        #         return 100.0
        #     else
        #         return -6.0
        #     end
        # end


# function mean_cost(m)
#    r_tot = 0.0
#    for i = 1:100, j = 1:100
#        r_tot += reward(m, GWPos(i,j))
#    end
#    return (r_tot-1600)/9984
# end
#
#
#
# n_range = (15, 30, 45, 60, 75, 90)
# d_range = (3,8,10,15,20)
# c_range = (10.0, 20.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0)
#
# for n in n_range
#     solver1 = solver_explore(n)
#     println(n)
#     evaluate(solver1, "hw3")
# end


# if [i,j] in keys(m.rewards)
#     println("reward!", [i,j])
# end

#submit(s3, "hw3", "maja8167@colorado.edu", nickname="not at the top")

##
# best n_iterations: n=20: -8.4, n=60: -1.4, n=55: 2.5
# best depths: d=8: 1.9,
# best exploration_constant: c=9,10: 7, c=15,20,22,35,50,55: 9, c=45: 14

###
#n: 45, d: 10, c: 5.0
#Evaluation complete! Score: 40.4162502022514
