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

function test_pl_reg_ll_grad(;X=nothing, beta=nothing, nsamp=100, K=5, m=3, n=[3])
    if (isnothing(X) || isnothing(beta))
        X = rand(m, nsamp)
        beta = rand(K-1, m)
        o = sim_reg_data(X, beta; n=n)
        beta_vec = reshape(beta, (K-1)*m)
    else
        o = sim_reg_data(X, beta; n=n)
        beta_vec = reshape(beta, (K-1)*m)
    end
    ll(beta_vec) = pl_reg_ll(beta_vec, X, o, K, nsamp)
    ad_grad_ll = ForwardDiff.gradient(ll, beta_vec)
    fd_grad_ll = FiniteDiff.finite_difference_gradient(ll, beta_vec)
    return ad_grad_ll, fd_grad_ll
end

# ad_grad_ll, fd_grad_ll = test_pl_reg_ll_grad()
# ad_grad_ll, fd_grad_ll = test_pl_reg_ll_grad(; n=[2, 3])
# ad_grad_ll, fd_grad_ll = test_pl_reg_ll_grad(; n=[missing])
# X = rand(3, 100)
# beta = zeros(4, 3) .- 5.0
# beta*X
# ad_grad_ll, fd_grad_ll = test_pl_reg_ll_grad(;X=X, beta=beta, n=[missing])
# ad_grad_ll, fd_grad_ll = test_pl_reg_ll_grad(;X=X, beta=beta, n=[3, 2])
# maximum(abs.(ad_grad_ll .- fd_grad_ll))
# minimum(abs.(ad_grad_ll .- fd_grad_ll))

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

X = rand(3, 10_000)
beta = zeros(4, 3) .- 5.0
beta*X
@time beta, beta_hat, mle= test_pl_reg(X=X, beta=beta)

# some testing of forwarddiff

function test_fun1(x::Vector{T}) where T<:Real
    return sum(2.0.*x)
end

function test_fun2(x::Vector{T}) where T<:Real
    x = reshape(x, length(x)÷2, 2)
    return sum(2.0*x)
end

x = ones(5, 2)
test_fun2(x)

ForwardDiff.gradient(test_fun1, ones(10))
ForwardDiff.gradient(test_fun2, zeros(5*2))

function test_fun3!(x::Vector{T}) where T<:Real
    x[1] = 2.0
end

x = ones(2*5)
test_fun3!(x)