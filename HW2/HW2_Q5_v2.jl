using DMUStudent
using DMUStudent.HW2
using LinearAlgebra
using Profile

const g = 0.99
const e = 0.01

function ValueIteration(size_s, R, T)
    U = zeros(Float64, size_s);
    error = 100
    first = true
    while error > 0.1
        Q = zeros(Float64, (3,size_s))
        U_k = zeros(Float64, size_s);
        for a in 1:3
            Q[a,:]= R[a] + g*(T[a]*U)
        end
        for s in 1:size_s
            U_k[s] = maximum(Q[:,s])
        end
        error = maximum(abs.(U-U_k));
        println(">  ", error)
        U = U_k
    end
    return U
end

function RunEvaluation(d)
    n = d
    m = UnresponsiveACASMDP(n)
    T = transition_matrices(m, sparse=true)
    R = reward_vectors(m)
    size_s = length(R[1])

    T_arr = [T[i] for i in 1:length(T)]
    R_arr = [R[i] for i in 1:length(R)]
    println("Discretization: ", n)
    v = @time ValueIteration(size_s, R_arr, T_arr);
    return v
end

v19 = @time RunEvaluation(19)
