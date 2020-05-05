using POMDPs
using QuickPOMDPs
using POMDPModelTools
using POMDPSimulators
using POMDPPolicies
using Random
using Plots
using LinearAlgebra
#using IJulia

S = 1:10 # same as [1,2,3,4,5,6,7, 8, 9, 10]
A = [-1, 1]

function T(s, a, sp)
    if sp == clamp(s + a, 1, 10)
        return 0.75
    elseif sp == clamp(s - a, 1, 10)
        return 0.25
    else
        return 0.0
    end
end

function R(s, a)
    if s == 8
        return 10.0
    else
        return 0.0
    end
end

gw = DiscreteExplicitMDP(S,A,T,R,γ);

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
