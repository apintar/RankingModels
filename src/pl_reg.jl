function sim_reg_data(X::AbstractMatrix{T},
    beta::AbstractMatrix{T};
    n::AbstractVector{U}=[missing]) where {T<:Real, U<:Union{Integer, Missing}}
    n_obs = size(X)[2]
    K = size(beta)[1] + 1
    !ismissing(n[1]) || (n = [K])
    # in case n is different from 1 or n_obs
    n = repeat(n, outer=Int64(ceil(n_obs/length(n))))
    n = n[1:n_obs]
    o = Matrix{Int64}(undef, K, n_obs)
    logit_p = beta*X
    for j=1:n_obs
        tmp = inv_logit(logit_p[:, j])
        # part_rand returns a nx1 matrix here, so we take the first column
        o[:, j] = part_rand(PlackettLuce(tmp), n[j], 1)[:, 1]
    end
    return o
end

function pl_reg_ll(beta::AbstractVector{R},
    X::AbstractMatrix{S},
    o::AbstractMatrix{T},
    K::Int64,
    n_obs::Int64) where {R<:Real,S<:Real,T<:Integer}

    beta_mat = reshape(beta, K-1, size(X)[1])
    logit_p = beta_mat * X
    ll = 0.0
    for i = 1:n_obs
        p = inv_logit(logit_p[:, i])
        sum_p = 1.0
        for j = 1:K
            # orders should have all zeros (non ordered) at the end, so break and
            # return when the first one is encountered
            ((o[j, i] > 0) && (sum_p > 0)) || break
            ll += log(p[o[j, i]]) - log(sum_p)
            sum_p -= p[o[j, i]]
        end
    end
    return ll
end

function fit_pl_reg(X::AbstractMatrix{T},
    o::AbstractMatrix{S}) where {T<:Real,S<:Integer}

    K = size(o)[1]
    n_obs = size(o)[2]
    (size(X)[2] == n_obs) || error("must have size(o)[2] == size(X)[2]")
    m = size(X)[1]
    beta0 = rand((K - 1)*m)
    f(beta) = -pl_reg_ll(beta, X, o, K, n_obs)
    # mle = optimize(f, beta0, BFGS(); autodiff=:forward)
    mle = optimize(f, beta0, method=NelderMead(), iterations=10_000)
    return mle
end
