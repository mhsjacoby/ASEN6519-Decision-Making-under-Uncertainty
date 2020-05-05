using POMDPs
using QuickPOMDPs
using Distributions
using POMDPPolicies
using POMDPSimulators


S = [0,1,2] # same as [1,2,3,4,5,6,7, 8, 9, 10]
A = [-1, 0, 1]
g = .95

function T(s, a, sp)
    if sp == clamp(s + a, -1, 1)
        return 0.
    elseif sp == clamp(s - a, 0,1)
        return 0.95
    else
        return 0.0
    end
end

function R(s, a)
    if s == 0
        return 10.0
    else
        return 0.0
    end
end

gw = DiscreteExplicitMDP(S,A,T,R,g);

function POMDPModelTools.render(m::typeof(gw), step)
    str = "|"
    for s in states(m)
        if s == step.s
            str *= "s|"
        else
            str *= " |"
        end
    end
    return str
end

policy = FunctionPolicy(s->1);
ds = DisplaySimulator(max_steps=20, max_fps=100)
policy = FunctionPolicy(s->fp(s));


simulate(ds, gw, policy)

# Solving
solver = ValueIterationSolver(max_iterations=100, belres=1e-6, verbose=false); # creates the solver
curr_policy = solve(solver, gw)






# M = mountaincar([0,1])
# solver = ValueIterationSolver(max_iterations=50, belres=1e-6, verbose=false)
# policy = solve(solver, M)




# m = QuickMDP(
#     function G(s, a)
#         sp = s+1
#         r = -s
#         return (sp=sp, r=r)
#     end,
#     initialstate_distribution = Uniform(0,1,2),
#     actiontype = Int32
# );
#
# function eval_k(K)
#     function pfunc(s)
#         return -K*s
#     end
#     policy = FunctionPolicy(pfunc)
#     sim = RolloutSimulator(max_steps=100)
#     r = simulate(sim, m, policy)
#     return r
# end

function MonteCarloPolicyEval(k)
    u = []
    for i in 1:1000
        curr_r = eval_k(k)
        append!(u,curr_r)
    end
    return mean(u)
end
