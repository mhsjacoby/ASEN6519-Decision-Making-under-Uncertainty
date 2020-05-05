using Plots
using Flux
using StaticArrays
using Statistics


function MyData(n)
    x = rand(n)
    y = cos.(20 * x.^2)
    return ([(SVector(x[i]), SVector(y[i])) for i in 1:length(x)], x)
end

function train_model(data_train, dx, data_test, dy, N_epochs)
    m = Chain(Dense(1,50,σ), Dense(50,50,σ), Dense(50,1))
    loss(x, y) = Flux.mse(m(x), y)
    ps = Flux.params(m)

    x_train = [x[1] for x in data_train]
    y_train = [y[2] for y in data_train]
    x_test = [x[1] for x in data_test]
    y_test = [y[2] for y in data_test]
    Losses = Array{Any}(undef, N_epochs)

    for i in 1:N_epochs
        Flux.train!(loss, ps, data_train, ADAM())
        L = loss.(x_test, y_test)
        Losses[i] = mean(L)
    end
    p = plot(sort(dy), x->(cos(20*x^2)), title="Actual Function")
    scatter_trained = scatter!(p, dy, [first(y) for y in m.(x_test)])
    plot(scatter_trained, xlabel="x", ylabel="f(x)",
        title="Fit of 100 Points on Trained Model")
    savefig("DMU_HW4_Q1_fit2")
    return Losses
end

D_train = MyData(500)
train = D_train[1]
dx = D_train[2]

D_test = MyData(100)
test = D_test[1]
dy = D_test[2]

N = 1000

Losses = train_model(train, dx, test, dy, 1000)

### Plot and save the error plots
plot_error = plot(1:N, Losses, xlabel="Number Epochs", ylabel="Average MSE",
    title="MSE as a Function of Training Epochs", legend=false)
savefig("DMU_HW4_Q1_error")

plot_error_zoom = plot(500:N, Losses[500:N], xlabel="Number Epochs", ylabel="Average MSE",
    title="MSE as a Function of Training for High Number of Epochs", legend=false)
savefig("DMU_HW4_Q1_error_zoom")
