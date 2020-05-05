using DMUStudent
using RLInterface
using POMDPs
using POMDPModels
using ElectronDisplay
ElectronDisplay.CONFIG.single_window = true
using DeepQLearning
using Flux
using POMDPPolicies
using POMDPSimulators
using Random

### Deep Q Method
mc = HW4.mc;
mtnCar = RLInterface.MDPEnvironment(mc.problem, Vector{Float32})

actionsA = [-1.0, -0.5, 0.0, 0.5, 1.0]
RLInterface.actions(::typeof(mtnCar)) = actionsA
RLInterface.action(::typeof(RandomPolicy(mtnCar.problem)), ::typeof(reset!(mtnCar))) = rand(actionsA)
model = Chain(Dense(2,64), Dense(64,64),  Dense(64,5));

solver = DeepQLearningSolver(qnetwork=model, max_steps=2000000,
                             learning_rate=0.001, prioritized_replay=true,
                             exploration_policy = max_energy, buffer_size = 50000,
                             train_start = 1000, max_episode_length = 500)
policy = solve(solver, mtnCar)

function max_energy(policy, env, obs, global_step, rng)
    s1, s2 = env.state
    if global_step < 1200000
        if s2 < 0.0
            return (-1.0, global_step)
        else
            return (1.0, global_step)
        end
    else
        return (policy(env.state), global_step)
    end
end


### probably don't include....

# function Discretize(a, b, k) # Unifomly discretize from a to b with step size k
#     D = Dict()
#     for (i,j) in zip(a:k:b, 1:(Int(floor((b-a)/k))))
#         D[i] = j
#     end
#     return D
# end
#
# function get_state(d, x)
#     L = 0
#     for key in sort(collect(keys(d)))
#         if x  <= key
#             return d[key]
#         end
#         L = key
#     end
#     return d[L]
# end

# actionsA = Dict(-0.5 => 1, -0.1 => 2, 0.1 => 3, 0.5 => 4, 1 => 5)
# stateX = Discretize(-1.4, 0.6, 0.1)
# stateV = Discretize(-0.08, 0.08, .02)



# function ExploreSpace(m, N)
#     A = actions(m)
#     s = reset!(m)
#     done = false
#
#     @progress for t in 1:N
#         a = rand(A)
#         sp, r, done, info = step!(m, a)
#         if done == true
#             println("Goal reached. state $sp, action $a")
#             break
#         end
#
#         if a < min_a
#             min_a = a
#         elseif a > max_a
#             max_a = a
#             # println("new max a $a")
#         end
#
#         if s[1] < min_x
#             min_x = s[1]
#         elseif s[1] > max_x
#             max_x = s[1]
#         end
#
#         if s[2] < min_v
#             min_v = s[2]
#         elseif s[2] > max_v
#             max_v = s[2]
#         end
#
#         # if s[1] < -0.99
#         # electrondisplay(RLInterface.render(m))
#         # println(s)
#         # end
#         s = sp
#     end
#     x = (min_x, max_x)
#     v = (min_v, max_v)
#     a = (min_a, max_a)
#     return x, v, a
# end





### Explore to learn about state space
# Maybe include...

# function ExploreSpace(m, N)
#     A = actions(m)
#     s = reset!(m)
#     done = false
#     x = get_x(s[1])
#     v = get_v(s[2])
#     r_total = 0
#
#     @progress for t in 1:N
#         # a = rand(A)
#         a = policy(v)
#         sp, r, done, info = step!(m, a)
#         r_total += r
#         xp = get_x(sp[1])
#         vp = get_v(sp[2])
#         # println(xp, vp)
#         if done == true
#             println("Goal reached. state $sp, action $a")
#             println("step $t")
#             println("reward $(r_total)")
#             break
#         end
#         s = sp
#     end
# end
#
#
# n = 100000
# X, V, A = ExploreSpace(mtnCar, n)
# println("\nN steps $n")
# println(" x $(X[1]), $(X[2]);\n v $(V[1]), $(V[2])")
#
# ExploreSpace(mtnCar, n)
### include in traditional

function get_x(x)
    if x < -1.2
        x = -1.2
    elseif x > 0.5
        x = 0.5
    end
    return round(Int, x*30)+37
end

function get_v(v)
    return round(Int, v*150)+16
end

function max_energy_trad(env) #policy, env, obs, global_step, rng)
    x, v = env
    if v < 0.0
        return -1.0
    else
        return 1.0
    end
end

function max_direction_policy(env)
    x, v = env
    vi = get_v(v)
    if  vi < 0.01 && vi > -0.01
        a = 0.0
        # if x < 0.0
        #     a = -0.5
        # else
        #     a = 0.5
        # end
    else
        if x > -.98 && v < 0.0
            a = -1.0
        else
            a = 1.0
        end
    end
    return a
end


actionsA = [-1.0, -0.5, 0.0, 0.5, 1.0]
actions_ind = Dict(-1.0=>1, -0.5 => 2, 0.0 => 3, 0.5 => 4, 1 => 5)


###
# function sarsa_Q_learn(m, Q, alph, max_t, i, g = 0.95)
#     A = actionsA
#     s = reset!(m)
#     done = false
#     rsum = 0.0
#     t = 1
#     a = rand(A)
#     while t <= max_t
#
#         x = get_x(s[1])
#         v = get_v(s[2])
#         ai = actions_ind[a]
#
#         sp, r, done, info = step!(m, a)
#         xp = get_x(sp[1])
#         vp = get_v(sp[2])
#
#         if rand() < eps
#             ap = rand(A)
#         else
#             if i < switch_step
#                 ap = max_energy_trad(s)
#             else
#                 global switch
#                 if switch == false
#                     display("using Q matrix now...")
#                     switch = true
#                 end
#                 ap = A[argmax(Q[x, v, :])]
#             end
#         end
#         api = actions_ind[ap]
#
#
#         Q[x, v, ai] += alph * (r + g*Q[xp, vp, api] - Q[x, v, ai])
#
#         if done
#             return Q
#         end
#         s = sp
#         a = ap
#         t += 1
#     end
#     return Q
# end


function max_direction_policy(env)
    x, v = env
    if x > -1.1 && min_x > -0.95 && v < 0.0
        a = -1.0
    else
        a = 1.0
    end
    return a
end

function heuristic_sarsa(m, Q, alph, max_t, g = 0.95)
    A = actionsA
    s = reset!(m)
    done = false
    rsum = 0.0
    t = 1
    a = rand(A)
    min_x = 0.0
    while t <= max_t
        x = get_x(s[1])
        v = get_v(s[2])
        ai = actions_ind[a]

        sp, r, done, info = step!(m, a)
        xp = get_x(sp[1])
        vp = get_v(sp[2])

        if rand() < 0.1
            ap = rand(A)
        else
            if xp > -1.1 && min_x > -0.95 && vp < 0.0
                ap = -1.0
            else
                ap = 1.0
        end
            #
            # if i < switch_step
            #     ap = max_energy_trad(s)
            # else
            #     global switch
            #     if switch == false
            #         display("using Q matrix now...")
            #         switch = true
            #     end
            #     ap = A[argmax(Q[x, v, :])]
            # end
        end
        api = actions_ind[ap]
        if min_x < xp
            min_x = xp
        end


        Q[x, v, ai] += alph * (r + (g^t)*Q[xp, vp, api] - Q[x, v, ai])

        if done
            return Q
        end
        s = sp
        a = ap
        t += 1
    end
    return Q
end


function train_Q(m, n, a, max_t)
    display("training Q....")
    Q = zeros(52,30,5)
    for i in 1:n
        Q = heuristic_sarsa(m, Q, a, max_t)
    end
    return Q
end


# function test_policy(m, Q, max_t)
#     display("testing...")
#     A = actionsA
#     s = reset!(m)
#     done = false
#     r_sum = 0
#     t = 1
#     while t <= max_t
#         x = get_x(s[1])
#         v = get_v(s[2])
#         a = A[argmax(Q[x, v, :])]
#
#         sp, r, done, info = step!(m, a)
#         r_sum += r
#         if done
#             break
#             println("breaking, $(r_sum)")
#         end
#         s = sp
#         t+=1
#     end
#     return r_sum
# end



function train_test(m, a, n, max_t)
    display("starting ....")
    Q = train_Q(m, n, a, max_t)
    # p = test_policy(m, Q, T)
    return Q
end


a = 0.01 #learning rate, alpha
e = 0.2 #epsilon
n = 1000000 #number of episodes for training
max_t = 1000
switch_step = Int(n*0.75)
global switch = false



println("a $a, e $e, t $n")
r_sarsa = train_test(MC, a, n, max_t)

function sarsa_policy(s, Q=r_sarsa, A=actionsA)
    x = get_x(s[1])
    v = get_v(s[2])
    a = A[argmax(Q[x, v, :])]
    return a
end




# curr_policy = sarsa_policy()



### View a state

function view_state(m)
    s = reset!(m)
    done = false
    # disp_s = Array{Fl}
    # display(s)
    min_x = 0
    for t in 1:200
        if s[1] > -1.2 && min_x > -0.95 && s[2] < 0.0
            a = -1.0
            # display("left")
        # elseif s[1] > -1.2 && s[2] > 0.0
        #     a = 1.0
        #     display("right")
        else
            a = 1.0
            # display("right")
        end

        if s[1] < min_x
            min_x = s[1]
        end
        if done
            display("min x: $(min_x)")
            display("time step: $(t)")
            break
        end


        sp, r, done, info = step!(m, a)
        # display("action: $a, x: $(sp[1]), v: $(sp[2])")
        electrondisplay(RLInterface.render(m))
        s = sp
        t +=1
    end
end

MC = HW4.mc;

view_state(MC)
### don't include

#     s = reset!(m)
#     done = false
#
#     @progress for t in 1:N
#         a = rand(A)
#         sp, r, done, info = step!(m, a)

# electrondisplay(RLInterface.render(m))
#
# function ExploreSpace(m, N=5000)
#     A = actions(m)
#     s = reset!(m)
#     done = false
#
#     @progress for t in 1:N
#         a = rand(A)
#         sp, r, done, info = step!(m, a)
#         if done == true
#             println("Goal reached. state $sp, action $a")
#             break
#         end
#
#         if s[1] < -1.2
#             electrondisplay(RLInterface.render(m))
#             println(s)
#             break
#         end
#         s = sp
#     end
#     return
# end
#
# ExploreSpace(MC)
