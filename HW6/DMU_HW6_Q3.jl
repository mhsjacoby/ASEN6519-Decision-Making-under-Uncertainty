using POMDPs
using POMDPModels
using POMDPSimulators
using SARSOP
using QMDP
using BasicPOMCP
using DMUStudent
using DMUStudent.HW6

using ParticleFilters
using POMCPOW


# solver = POMCPOWSolver(criterion=MaxUCB(26.0), k_action=4.0, k_observation=4.0)

Q_planner = solve(QMDPSolver(), lasertag)
up = SIRParticleFilter(lasertag, 1000)



DMUStudent.submit(
    (Q_planner,up),
    "hw6",
    "maja8167@colorado.edu",
    nickname="mhsj"
)

ds = DisplaySimulator(max_steps=30, extra_final=false, extra_initial=true)
simulate(ds, lasertag, Q_planner)

DMUStudent.evaluate(
    (Q_planner,up),
    "hw6",
    n_episodes=100
)
