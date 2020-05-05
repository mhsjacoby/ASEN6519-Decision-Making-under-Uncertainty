using POMDPs
using POMDPModels
using POMDPModelTools
using BeliefUpdaters
using POMDPPolicies
using POMDPSimulators
using QuickPOMDPs
using BeliefUpdaters
include("DMU_HW5_Q2_probs.jl")


S = [:healthy, :in_situ, :invasive, :death]
A = [:wait, :test, :treat]
O = [:pos, :neg]
γ = 0.99
s0 = Deterministic(:healthy)
term = Set([:death])

m = DiscreteExplicitPOMDP(S, A, O, T, Z, R, γ, s0, terminals=term)


wait_policy = FunctionPolicy(
    function (o)
        return :wait
    end)


function simulate_policy(m, N, policy)
    up = DiscreteUpdater(m);
    rsum = 0.0
    for i in 1:N
        sim = RolloutSimulator(max_steps=10000)
        rsum += simulate(sim, m, policy)#, up)
    end
    return rsum/N
end;

p = FunctionPolicy(
    function (b)
        if b.b[3] > 0.02
            return :treat
        elseif b.b[2] > 0.25
            return :treat
        elseif b.b[2] > 0.01
            return :test
        else
            return :wait
        end
end);

N = 100000
avg_reward = simulate_policy(m, N, wait_policy)
display("N: $N")
display("Average reward: $(avg_reward)")
