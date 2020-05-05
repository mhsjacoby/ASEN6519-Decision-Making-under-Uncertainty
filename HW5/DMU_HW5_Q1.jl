using POMDPs
using POMDPModels
using POMDPModelTools
using BeliefUpdaters
using POMDPPolicies
using POMDPSimulators
using QuickPOMDPs
using BeliefUpdaters

#Crying Baby Problem
r_feed = -5.0
r_hungry = -10.0
p_become_hungry = 0.2
p_cry_when_hungry = 0.6
p_cry_when_not_hungry = 0.1
γ = 0.9
m = BabyPOMDP(r_feed, r_hungry,
              p_become_hungry,
              p_cry_when_hungry,
              p_cry_when_not_hungry,
              γ)

updater = DiscreteUpdater(m);
alpha_v = 0.19

cry_dict = Dict(true => "crying", false => "not crying")
act_dict = Dict(true => "feed", false => "don't feed")

function run_scenario(up, m, T)
    b = initialize_belief(up, Deterministic(false));
    o = false;
    for t in 1:T
        display("time: $t")
        p_hungry = b.b[2]
        a = false
        # o = false
        # a = act(p_hungry)
        display("hungry: $(round(p_hungry, digits=2))")
        display("action: $(act_dict[a])")
        display("observation: $(cry_dict[o])")
        println();
        b = update(up, b, a, o)
        o = rand(cry_dict).first
     end
end

function act(b, alpha = alpha_v)
    if b < alpha
        return false
    else
        return true
    end
end

run_scenario(updater, m, 20)
