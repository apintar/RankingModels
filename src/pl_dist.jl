struct PlackettLuce{S<:Integer, TV<:AbstractVector} <: DiscreteMultivariateDistribution
    K::S
    p::TV
    function PlackettLuce{S, TV}(K::S, p::TV) where {S<:Integer, TV<:AbstractVector}
        check1 = isprobvec(p)
        check2 = length(p) == K
        check1 && check2 ? new(K, p) : error("invalid PlackettLuce parameters")
    end
end

function PlackettLuce(K::S, p::TV) where {S<:Integer, TV<:AbstractVector}
    PlackettLuce{S, TV}(K, p)
end

function PlackettLuce(p::TV) where TV<:AbstractVector
    PlackettLuce(length(p), p)
end

ncategories(d::PlackettLuce) = d.K
Base.length(d::PlackettLuce) = d.K
Base.eltype(d::PlackettLuce) = Int64

function random_order!(rng::AbstractRNG, p::AbstractVector{T}, 
                       K::Integer, n::Integer, 
                       o::AbstractVector{S}) where {T<:Real, S<: Integer}
    p = copy(p)
    o_choose = collect(1:K)
    sum_p = sum(p)
    isapprox(sum_p, 1.0) || throw(DomainError(sum_p, "sum_p must be 1.0"))
    for i=1:n
        # at iteration K, there is only one choice left and the rest of the
        # loop can be skipped
        (i < K) || (o[i] = o_choose[1]; break)
        choice_idx = rand(rng, Categorical(p))
        o[i] = o_choose[choice_idx]
        # if i == n, the rest of the loop can be skipped
        (i < n) || break
        deleteat!(o_choose, choice_idx)
        sum_p -= p[choice_idx]
        # throw and error if sum_p == 0
        (sum_p > 0) || throw(DomainError(sum_p, "sum_p must be positive; check p and/or use part_rand with a smaller value for n"))
        deleteat!(p, choice_idx)
        p ./= sum_p
        # reset sum_p to 1
        sum_p = 1.0
    end
    return o
end

function Distributions._rand!(rng::AbstractRNG, d::PlackettLuce, 
                              o::AbstractVector{T}) where T<:Integer
    return random_order!(rng, d.p, d.K, d.K, o)
end

function part_rand(rng::AbstractRNG, d::PlackettLuce, n::Integer, nsamp::Integer)
    o = zeros(Int64, d.K, nsamp) 
    for j=1:nsamp
        # need @view because o[:, j] makes a copy by default
        random_order!(rng, d.p, d.K, n, @view(o[:, j]))
    end
    return o
end

# so it's not essential to pass in a random number generator
part_rand(d::PlackettLuce, n::Integer, nsamp::Integer) = part_rand(Random.GLOBAL_RNG, d, n, nsamp)

function order_to_ranking!(o::AbstractVector{T}, r::AbstractVector{T}, n::T) where T<:Integer
    fill!(r, zero(eltype(r)))
    for i=1:n
        r[o[i]] = i
    end
    return r
end

function order_to_ranking(o::AbstractVector{T}, n::T) where T<:Integer
    r = Vector{Int64}(undef, length(o))
    order_to_ranking!(o, r, n)
    return r
end

function ranking_to_order!(r::AbstractVector{T}, o::AbstractVector{T}) where T<:Integer
    fill!(o, zero(eltype(o)))
    for i = 1:length(r)
        iszero(r[i]) || (o[r[i]] = i)
    end
    return o
end

function ranking_to_order(r::AbstractVector{T}) where T<:Integer
    o = Vector{Int64}(undef, length(r))
    ranking_to_order!(r, o)
    return o
end

function Distributions._logpdf(d::PlackettLuce, x::AbstractVector{T}; ro="order") where T<:Integer
    if (ro == "ranking") 
        o = ranking_to_order(d, x)
    else
        o = x
    end
    sum_p = sum(d.p)
    ll = 0.
    for i in 1:d.n
        ll += (log(d.p[o[i]]) - log(sum_p))
        sum_p -= d.p[o[i]]
    end
    return ll
end

function inv_logit(logit_p::AbstractVector)
    Km1 = length(logit_p)
    p = ones(eltype(logit_p), Km1+1)
    p[1:Km1] = exp.(logit_p)
    return p./sum(p)
end

function pl_ll(logit_p::AbstractVector, o::AbstractMatrix)
    p = inv_logit(logit_p)
    ll = 0.
    for i=1:size(o)[2]
        sum_p = 1.
        for j=1:size(o)[1]
            ll += log(p[o[j, i]]) - log(sum_p)
            sum_p -= p[o[j, i]]
        end
    end
    return ll
end

function fit_pl(o::AbstractMatrix, K::T) where T<:Integer
    p = zeros(Float64, K)
    p_tmp = counts(o[1, :])
    p[1:length(p_tmp)] = p_tmp
    p .+= 1.
    p ./= sum(p)
    logit_p0 = log.(p[1:(K-1)]./p[K])
    f(logit_p) = -pl_ll(logit_p, o)
    optim_res = optimize(f, logit_p0)
    logit_p = Optim.minimizer(optim_res)
    p = inv_logit(logit_p)
    return PlackettLuce(K, size(o)[1], p)
end

function Distributions.fit_mle(::Type{<:PlackettLuce}, x::Matrix{<:Integer}; ro="order")
    if ro == "ranking"
        n = maximum(skipmissing(x))
        nsamp = size(x)[2]
        o = zeros(Int64, n, nsamp)
        for i=1:nsamp
            ranking_to_order!()
        end
    else
        o = x
    end
end
