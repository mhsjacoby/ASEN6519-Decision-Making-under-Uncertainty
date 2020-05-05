using POMDPs
using QuickPOMDPs
using POMDPModelTools
using POMDPSimulators
using POMDPPolicies
using Random
using Plots
using LinearAlgebra
using DiscreteValueIteration

S = 1:19 #1:9 without key, 10:18 with key, 19 is the terminal state
A = [-1, 1]
γ = 0.95

function T_m(s, a, sp) ## there are probably moree compact ways to do this...
    if s == 2 # transition from non-key to key state (2 to 11)
        if sp == 12
            return 0.9
        elseif sp == 10
            return 0.1
        else
            return 0.0
        end
    elseif s == 9 #hitting the wall in state 9 (right side)
        if sp == 8
            return 0.9
        elseif sp == 9
            return 0.1
        else
            return 0.0
        end
    elseif s == 10 #hitting the wall in state 10 (left side)
        if sp == 11
            return 0.9
        elseif sp == 10
            return 0.1
        else
            return 0
        end
    elseif s == 17 # terminate
        if sp == 19
            return 1.0
        else
            return 0.0
        end
    else
        if sp == clamp(s + a, 1, 18)
            return 0.9
        elseif sp == clamp(s - a, 1, 18)
            return 0.1
        else
            return 0.0
        end
    end
end

function R_m(s,a)
    if s == 17
        return 10.0
    else
        return 0.0
    end
end

function fp(s)
    right = union([1,2],collect(10:17))
    left = union(collect(3:9),[18,19])
    if in(s,right)
        return 1
    elseif in(s,left)
        return -1
    end
end

ds = DisplaySimulator(max_steps=20, max_fps=100)
policy = FunctionPolicy(s->fp(s));

#init = Uniform(1:9)
init = Uniform(9)
term = Set(19)
gw = DiscreteExplicitMDP(S,A,T_m,R_m,γ, init, terminals=term);


function POMDPModelTools.render(m::typeof(gw), step) # modified from Zach's code
    str = "|"
    for s in states(m)
        if s <= 9
            if s == step.s
                str *= "s|"
            else
                str *= " |"
            end
        elseif s < 19                       # jump to the key states
            if s == step.s
                str *= "k|"
            else
                str *= " |"
            end
        end
    end
    if step.s <= 9
        return SubString(str,1,19)          # without key
    else
        return SubString(str,19,37)         # with key
    end
end

simulate(ds, gw, policy)

# Solving
solver = ValueIterationSolver(max_iterations=100, belres=1e-6, verbose=false); # creates the solver
curr_policy = solve(solver, gw)

S = 9
v = value(curr_policy, S)
print("Value at state ", S, ": ", v)
