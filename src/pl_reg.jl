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