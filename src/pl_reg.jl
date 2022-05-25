function sim_reg_data(X::AbstractMatrix{T},
    beta::AbstractMatrix{T};
    n::AbstractVector{U}=[missing]) where {T<:Real, U<:Union{Integer, Missing}}
    n_obs = size(X)[2]
    K = size(beta)[1] + 1
    !ismissing(n[1]) || (n = [K])
    # in case n is different from 1 or n_obs
    n = repeat(n, outer=Int64(ceil(n_obs/length(n))))
    println(n)
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

function pl_reg_ll(beta::AbstractMatrix{T}, 
                   X::AbstractMatrix{T}, 
                   o::AbstractMatrix{S},
                   K::Int64,
                   n::Int64) where {T<:Real, S<:Integer}

    logit_p = Matrix{Float64}(undef, K, n)
end

function fit_pl_reg(X::AbstractMatrix{T}, 
                    o::AbstractMatrix{S}) where {T<:Real, S<:Integer}
    K = size(o)[1]
    n = size(o)[2]
    (size(X)[2] == n) || error("must have size(o)[2] == size(X)[2]")
end