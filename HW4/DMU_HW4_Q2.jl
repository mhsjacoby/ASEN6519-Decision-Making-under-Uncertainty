using POMDPs
using POMDPModels
using TabularTDLearning
using POMDPPolicies
using RLInterface
using POMDPModelTools
using DMUStudent
using ElectronDisplay
using Statistics
using Plots

## Map states and actions to integers
a_ind = Dict(:right => 1, :down => 2, :left => 3, :up => 4)
s_ind = Dict([i,j] => 10*(i-1)+j for i in 1:10 for j in 1:10 )
s_ind[[-1,-1]] = 101

### Single and double Q learning algorithms
function Q_learn(m, Q, alph, eps, max_t, g = 0.95)
    A = actions(m)
    s = reset!(m)
    done = false
    rsum = 0.0
    t = 1
    while t <= max_t
        si = s_ind[s]

        if rand() < eps
            a = rand(A)
        else
            a = A[argmax(Q[si, :])]
        end

        ai = a_ind[a]
        sp, r, done, info = step!(m, a)
        spi = s_ind[sp]
        Q[si,ai] += alph * (r + g*argmax(Q[spi, :]) - Q[si,ai])

        if done
            return Q
        end
        s = sp
        t += 1
    end
    return Q
end

###
function double_Q_learn(m, Q1, Q2, alph, eps, max_t, g = 0.95)
    A = actions(m)
    s = reset!(m)
    done = false
    rsum = 0.0
    t = 1
    while t <= max_t
        si = s_ind[s]
        Q = (Q1+Q2)/2

        if rand() < eps
            a = rand(A)
        else
            a = A[argmax(Q[si, :])]
        end

        ai = a_ind[a]
        sp, r, done, info = step!(m, a)
        spi = s_ind[sp]

        if rand() < 0.5
            api = argmax(Q1[spi, :])
            Q1[si,ai] += alph * (r + g*Q2[spi,api] - Q1[si,ai])
        else
            api = argmax(Q2[spi, :])
            Q2[si,ai] += alph * (r + g*Q1[spi,api] - Q2[si,ai])
        end

        if done
            return Q1, Q2
        end
        s = sp
        t += 1
    end
    return Q1, Q2
end

### Sarsa algorithm

function sarsa_Q_learn(m, Q, alph, eps, max_t, g = 0.95)
    A = actions(m)
    s = reset!(m)
    si = s_ind[s]
    done = false
    rsum = 0.0
    t = 1

    if rand() < eps
        a = rand(A)
    else
        a = A[argmax(Q[si, :])]
    end

    while t <= max_t
        si = s_ind[s]
        ai = a_ind[a]
        sp, r, done, info = step!(m, a)
        spi = s_ind[sp]

        if rand() < eps
            ap = rand(A)
        else
            ap = A[argmax(Q[si, :])]
        end

        api = a_ind[ap]
        Q[si,ai] += alph * (r + g*Q[spi,api] - Q[si,ai])

        if done
            return Q
        end
        s = sp
        a = ap
        t += 1
    end
    return Q
end

### Training function (use the Q learning functions above)
function train_Q(m, n, a, e, s, DQ, sarsa)
    Q1 = zeros(101,4)
    Q2 = zeros(101,4)
    Q = zeros(101,4)

    if DQ
        for i in 1:n
            Q1, Q2 = double_Q_learn(m, Q1, Q2, a, e, s)
        end
        return (Q1+Q2)

    elseif sarsa
        for i in 1:n
            Q = sarsa_Q_learn(m, Q, a, e, s)
        end
        return Q

    else
        for i in 1:n
            Q = Q_learn(m, Q, a, e, s)
        end
        return Q
    end
end

### test the trained Q functions (works for any Q alg)
function test_policy(m, Q, Num_runs, max_t)
    all_R = []
    for i in 1:Num_runs
        A = actions(m)
        s = reset!(m)
        done = false
        r_sum = 0
        t = 1
        while t <= max_t
            si = s_ind[s]
            a = A[argmax(Q[si, :])]
            sp, r, done, info = step!(m, a)
            r_sum += r
            if done
                break
                println("breaking, $(r_sum)")
            end
            s = sp
            t += 1
        end
        push!(all_R, r_sum)
    end
    return mean(all_R)
end

### Run all train/test algorithms
function train_test(m, a, e, n, DQ, sarsa)#, al, e, n_steps)
    println("starting to train and test algorithms...")
    N = 100        # Number of runs to average during testing
    T = 50         # Number of max steps to take per test run
    LC = []

    for episodes in 1:100
        Q = train_Q(m, episodes, a, e, n, DQ, sarsa)
        p = test_policy(m, Q, N, T)
        push!(LC, (episodes, p))
    end
    return LC
end

###
a = 0.01
e = 0.2
n = 500
my_gw = HW4.gw

println("a $a, e $e, t $n")
LC_single = train_test(my_gw, a, e, n, false, false)
R_Q = [x[2] for x in LC_single]
LC_double = train_test(my_gw, a, e, n, true, false)
R_DQ = [x[2] for x in LC_double]

LC_sarsa = train_test(my_gw, a, e, n, false, true)
R_sarsa = [x[2] for x in LC_sarsa]

print("Q $(maximum(R_Q)), QQ $(maximum(R_DQ)), sarsa $(maximum(R_sarsa))")

### Plot Learning Curve
R_x = [x[1] for x in LC_single]

plot(R_x, R_Q, xlabel="Number Episodes",
ylabel="Total Reward after 150 max steps",  label = "Single Q",
title="Learning curve comparison between 3 Q learning algorithms")#, legend=false)
plot!(R_x, R_DQ, label = "Double Q")
plot!(R_x, R_sarsa, label = "Sarsa")

savefig("DMU_HW4_Q2_compare3")

### Small Parametric Analysis
a_range = [0.2, 0.5, 0.8]
e_range = [0.2, 0.5, 0.8]
step_range = [20, 50, 100]

for a in a_range
    for e in e_range
        for s in step_range
            println("alpha $a, epsilon $e, max steps: $s")
            LC_single = train_test(my_gw, a, e, n, false)
            R_single = [x[2] for x in LC_single]
            LC_double = train_test(my_gw, a, e, n, true)
            R_double = [x[2] for x in LC_double]
            println("Q $(maximum(R_single)), QQ $(maximum(R_double))")
        end
    end
end
