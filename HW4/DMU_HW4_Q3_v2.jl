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

### Deep Q Learning attempt
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
################

### Traditional methods
## discreetize x and xdot
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

### max energy policy for exploring
function max_energy_trad(env) #policy, env, obs, global_step, rng)
    x, v = env
    if v < 0.0
        return -1.0
    else
        return 1.0
    end
end

## Heeuristic policy - go left until high enough, then go right
## this got my highest score. It doesn't involve any Q learning :(
function max_direction_policy(env)
    x, v = env
    if x > -.98 && v < 0.0
        return = -1.0
    else
        return = 1.0
    end
end

actionsA = [-1.0, -0.5, 0.0, 0.5, 1.0]
actions_ind = Dict(-1.0=>1, -0.5 => 2, 0.0 => 3, 0.5 => 4, 1 => 5)

### Use traditional Q learning methods - not included, other iterations of Q
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


a = 0.2 #learning rate, alpha
n = 500000 #number of episodes for training
max_t = 500

r_sarsa = train_Q(MC, n, a, max_t)

function sarsa_policy(s, Q=r_sarsa, A=actionsA)
    x = get_x(s[1])
    v = get_v(s[2])
    return A[argmax(Q[x, v, :])]
end


### View a state
function view_state(m)
    s = reset!(m)
    done = false
    min_x = 0
    for t in 1:200
        if s[1] > -1.2 && min_x > -0.95 && s[2] < 0.0
            a = -1.0
        else
            a = 1.0
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
        electrondisplay(RLInterface.render(m))
        s = sp
        t +=1
    end
end

MC = HW4.mc;
view_state(MC)
