using DMUStudent.HW1
using Plots

function GenerateGuesses(f, x1, x2)
    x4 = f([x1, x2])
    x4r = f([x2])
    return x4, x4r
end

function CalculateErrors(f, n, xs = [], xrand = [], sse = [])
    for i in 1:n
        x4, x4r = GenerateGuesses(f, rand(1:20), rand(1:20))
        se = sqrt((x4-x4r)^2)
        push!(sse, se)
    end
    return sum(sse)
end

N = 100000
x_errors = CalculateErrors(fx, N)
y_errors = CalculateErrors(fy, N)
println("Number of samples: ", N)
println("Total x errors: ", x_errors)
println("Total y errors: ", y_errors)

if x_errors > y_errors
    print("y is the Markov Process")
elseif x_errors < y_errors
    println("x is the Markov Process")
else
    println("Not enough information to tell")
end


### Previous attempt

# X1 = 1
# N = 10000  #Use N=500 for plotting
# tol = 0.001
#
# function GenerateSeries(x1, f, n, xs=[], xrand=[])
#     push!(xs, f([x1]))
#     push!(xrand, f([x1]))
#     for i in 2:n
#         push!(xs,f(xs))
#         x2 = f([x1])
#         push!(xrand, x2)
#         x1 = x2
#     end
#     return xs, xrand
# end
#
# x, x_random = GenerateSeries(X1, fx, N)
# y, y_random = GenerateSeries(X1, fy, N)
#
# ## Empirical distribution code from Zachary Sunberg
# function empirical_distribution(samples)
#     return [count(samples.==i)/length(samples) for i in 1:20]
# end
#
# println("Number of samples: ", N)
# println("Tolerance: ", tol)
#
# x_dist = empirical_distribution(x)
# rand_x_dist = empirical_distribution(x_random)
# x_markov = isapprox(x_dist, rand_x_dist, atol = tol)
# println("Is x the markov process? ", x_markov)
# plot(x, labels="x based on all previous")
# plot!(x_random, labels="x based on one previous", legend=:bottomright)
# savefig("x_vals.png")
#
# y_dist = empirical_distribution(y)
# rand_y_dist = empirical_distribution(y_random)
# y_markov = isapprox(y_dist, rand_y_dist, atol = tol)
# println("Is y the markov process? ", y_markov)
# plot(y, labels="y based on all previous")
# plot!(y_random, labels="y based on one previous", legend=:bottomright)
# savefig("y_vals.png")
