using POMDPs
using QuickPOMDPs
using Distributions
using POMDPPolicies
using POMDPSimulators

m = QuickMDP(
    function G(s, a, d=Normal())
        sp = 2*s + a + rand(d)
        r = -2*s^2-a^2
        return (sp=sp, r=r)
    end,
    initialstate_distribution = Normal(),
    actiontype = Float64
);

function eval_k(K)
    function pfunc(s)
        return -K*s
    end
    policy = FunctionPolicy(pfunc)
    sim = RolloutSimulator(max_steps=10)
    r = simulate(sim, m, policy)
    return r
end

function MonteCarloPolicyEval(k)
    u = []
    for i in 1:100
        curr_r = eval_k(k)
        append!(u,curr_r)
    end
    return mean(u)
end

function FullSearch(k_start, e, mult)
    k = k_start
    u_max = -Inf
    diff = Inf
    best_k = k_start
    while e*mult > 0.000001
        while diff > e*mult
            K_test = k
            println("in: ", k, " : ", u_max)
            k, u = NeighborSearch(mult, k, u_max)
            println("out: ", k, " : ", u)
            if u > u_max
                best_k, u_max = k, u
            end
            println(best_k, " : ", u_max)
            diff = abs(K_test-k)
        end
        mult = mult*.1
    end
    return k
end

function NeighborSearch(m, curr_k, curr_u)
    for j in 1:20
        new_k = curr_k + m*rand(Normal())
        u_x = MonteCarloPolicyEval(new_k)
        if u_x > curr_u
            curr_u = u_x
            curr_k = new_k
        end
    end
    return curr_k, curr_u
end

k_start = 2
eps = 0.1
mult = 1.5
x = FullSearch(k_start, eps, mult)
