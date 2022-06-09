function test_sim_reg_data(;X=nothing, beta=nothing, nsamp=100, K=5, m=3, n=[3])
    if (isnothing(X) || isnothing(beta))
        X = rand(m, nsamp)
        beta = rand(K-1, m)
        o = sim_reg_data(X, beta; n=n)
    else
        o = sim_reg_data(X, beta; n=n)
    end
    return o
end

# test_sim_reg_data()
# test_sim_reg_data(; n=[2, 3])
# test_sim_reg_data(; n=[missing])
# X = rand(3, 100)
# beta = zeros(4, 3) .- 5.0
# beta*X
# test_sim_reg_data(;X=X, beta=beta, n=[missing])
# test_sim_reg_data(;X=X, beta=beta, n=[3])

function test_pl_reg_ll(;X=nothing, beta=nothing, nsamp=100, K=5, m=3, n=[3])
    if (isnothing(X) || isnothing(beta))
        X = rand(m, nsamp)
        beta = rand(K-1, m)
        o = sim_reg_data(X, beta; n=n)
        beta_vec = reshape(beta, (K-1)*m)
        ll = pl_reg_ll(beta_vec, X, o, K, nsamp)
        beta1 = rand((K-1)*m)
        ll1 = pl_reg_ll(beta1, X, o, K, nsamp)
    else
        o = sim_reg_data(X, beta; n=n)
        beta_vec = reshape(beta, (K-1)*m)
        ll = pl_reg_ll(beta_vec, X, o, K, nsamp)
        beta1 = rand((K-1)*m)
        ll1 = pl_reg_ll(beta1, X, o, K, nsamp)
    end
    return ll, ll1
end

# test_pl_reg_ll()
# test_pl_reg_ll(; n=[2, 3])
# test_pl_reg_ll(; n=[missing])
# X = rand(3, 100)
# beta = zeros(4, 3) .- 5.0
# beta*X
# test_pl_reg_ll(;X=X, beta=beta, n=[missing])
# test_pl_reg_ll(;X=X, beta=beta, n=[3, 2])

function test_pl_reg(;X=nothing, beta=nothing, nsamp=100, K=5, m=3, n=[3])
    if (isnothing(X) || isnothing(beta))
        X = rand(m, nsamp)
        beta = rand(K-1, m)
        o = sim_reg_data(X, beta; n=n)
        mle = fit_pl_reg(X, o)
        beta_vec = reshape(beta, (K-1)*m)
        println(pl_reg_ll(beta_vec, X, o, K, nsamp))
        println(pl_reg_ll(Optim.minimizer(mle), X, o, K, nsamp))
    else
        o = sim_reg_data(X, beta; n=n)
        mle = fit_pl_reg(X, o)
        beta_vec = reshape(beta, (K-1)*m)
        println(pl_reg_ll(beta_vec, X, o, K, nsamp))
        println(pl_reg_ll(Optim.minimizer(mle), X, o, K, nsamp))
    end
    return beta, Optim.minimizer(mle), mle
end

beta, beta_hat, mle= test_pl_reg(nsamp=2000)
println(beta .- reshape(beta_hat, size(beta)...))
# test_pl_reg_ll(; n=[2, 3])
# test_pl_reg_ll(; n=[missing])
X = rand(3, 10_000)
beta = zeros(4, 3) .- 5.0
beta*X
beta, beta_hat, mle= test_pl_reg(X=X, beta=beta)
# test_pl_reg_ll(;X=X, beta=beta, n=[missing])
# test_pl_reg_ll(;X=X, beta=beta, n=[3, 2])
#