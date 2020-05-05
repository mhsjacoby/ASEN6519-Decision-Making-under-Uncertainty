using DMUStudent
using DMUStudent.HW2
using LinearAlgebra
using Profile

const g = 0.99
const e = 0.1

function ValueIteration(size_s, R, T)
    U = zeros(Float64, size_s);
    error = 100
    while error > e
        u_k = zeros(Float64, size_s);
        @time for s in 1:size_s
            A = Float64[]
            for a in 1:3
                curr_a = R[a][s] + g*sum(sp -> T[a][s,sp]*U[sp], 1:size_s);
                append!(A, curr_a);
            end
            u_k[s] = maximum(A);
        end
        error = maximum(abs.(U-u_k));
        println(">  ", error)
        U = u_k;
    end
    return U
end



function RunEvaluation(d)
    n = d
    m = UnresponsiveACASMDP(n)
    T = transition_matrices(m, sparse=true)
    R = reward_vectors(m)
    size_s = length(R[1])

    println("Discretization: ", n)
    v = @time ValueIteration(size_s, R, T);
    return v
end

v2 = RunEvaluation(2);




#<#<#<#<#<#<<#<#<#<#<<#<#<#<#<#<#<#<<#<#

function ValueIteration(size_s, R, T)
    U = zeros(Float64, size_s);
    error = 100
    u_k = zeros(Float64, size_s); ###
  ###
    while error > e
        A = zeros(Float64,3)
        @time for s in 1:size_s #loop over sp first??? - don't think I can
            for a in 1:3
                curr_a = R[a][s] + g*sum(sp -> T[a][s,sp]*U[sp], 1:size_s); #change the order of this to col-by-col?
                A[a] = curr_a
            end
            u_k[s] = maximum(A);
        end
        error = maximum(abs.(U-u_k)); #devectorize this?
        println(error)
        U = u_k;
    end
    return U
end




# function ValueIteration(size_s, R, T)
#     U = ones(size_s);
#     error = 100
#     while error > e
#         u_k = zeros(size_s);
#         for s in 1:size_s
#             A = Float64[]
#             for a in 1:3
#                 curr_a = R[a][s] + g*sum(sp -> T[a][s,sp]*U[sp], 1:size_s);
#                 append!(A, curr_a);
#             end
#             u_k[s] = maximum(A);
#         end
#         error = maximum(U-u_k);
#         println(error)
#         U = u_k;
#     end
#     return U
# end
