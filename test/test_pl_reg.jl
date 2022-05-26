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
        ll = pl_reg_ll(beta, X, o, K, nsamp)
        beta1 = rand(K-1, m)
        ll1 = pl_reg_ll(beta1, X, o, K, nsamp)
    else
        o = sim_reg_data(X, beta; n=n)
        ll = pl_reg_ll(beta, X, o, K, nsamp)
        beta1 = rand(K-1, m)
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
# 