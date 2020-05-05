using POMDPs
using POMDPModels
using POMDPSimulators
using POMDPModelTools
using BeliefUpdaters
using POMDPPolicies
using QuickPOMDPs
using BeliefUpdaters
using SARSOP
using QMDP
include("HW5_soln.jl")


c = DiscreteExplicitPOMDP(S, A, O, T, Z, R, 0.99,
                            Deterministic(:healthy),
                            terminals=Set([:death]));
t = TigerPOMDP();

function evalSolver(m)
    results = Dict{String, Float64}()
    for (key, solver) in ["SARSOP"=>SARSOPSolver(), "QMDP"=>QMDPSolver()]
        policy = solve(solver, m)
        N = 10000
        rsum = 0.0
        for i in 1:N
            rsum += simulate(RolloutSimulator(max_steps=500), m, policy)
        end
        results[key] = rsum/N
    end;
    return results
end

results_c = evalSolver(c);
results_t = evalSolver(t);
