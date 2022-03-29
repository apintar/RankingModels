struct PlackettLuce{S<:Integer, TV<:AbstractVector} <: DiscreteMultivariateDistribution
    K::S
    n::S
    p::TV
    function PlackettLuce{S, TV}(K::S, n::S, p::TV) where {S<:Integer, TV<:AbstractVector}
        check1 = (n > 0)
        check2 = (K >= n)
        check3 = isprobvec(p)
        check4 = length(p) == K
        check5 = sum(p .> 0) >= n
        check1 && check2 && check3 && check4 && check5 ? new(K, n, p) : error("invalid PlackettLuce parameters")
    end
end

function PlackettLuce(K::S, n::S, p::TV) where {S<:Integer, TV<:AbstractVector}
    PlackettLuce{S, TV}(K, n, p)
end

function PlackettLuce(n::S, p::TV) where {S<:Integer, TV<:AbstractVector}
    PlackettLuce(convert(typeof(n), length(p)), n, p)
end

ncategories(d::PlackettLuce) = d.K
Base.length(d::PlackettLuce) = d.n
Base.eltype(d::PlackettLuce) = Int64

function Distributions._rand!(rng::AbstractRNG, d::PlackettLuce, x::AbstractVector{T}) where {T<:Integer}
    p = copy(d.p)
    x_choose = collect(1:d.K)
    for i in 1:d.n
        choice_idx = rand(rng, Categorical(p))
        x[i] = x_choose[choice_idx]
        deleteat!(p, choice_idx)
        p ./= sum(p)
        deleteat!(x_choose, choice_idx)
    end
    return x
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
    
function order_to_ranking(d::PlackettLuce, o::AbstractVector{T}) where T<:Union{Integer, Missing}
    r = Vector{Union{eltype(o), Missing}}(undef, d.K)
    fill!(r, missing)
    for i=1:d.n
        r[o[i]] = i
    end
    return r
end

function ranking_to_order(d::PlackettLuce, r::AbstractVector{T}) where T<:Union{Integer, Missing}
    # wish there was a way for eltype(r) to only provide the Integer part and
    # not the Missing part
    o = Vector{eltype(r)}(undef, d.n)
    for i = 1:d.K
        ismissing(r[i]) || (o[r[i]] = i)
    end
    return o
end

function test_rand(;p=nothing, K=5, nsamp=10000)
    isnothing(p) && (p = rand(Uniform(), K))
    p = p./sum(p)
    d = PlackettLuce(5, p)
    x = rand(d, nsamp)
    y = counts(x[1, :])./nsamp
    return (abs.(p - y)./p)*100
end

function test_ro_trans(;p=nothing, n=3, K=5)
    isnothing(p) && (p = rand(Uniform(), K))
    p = p./sum(p)
    d = PlackettLuce(n, p)
    o = rand(d)
    println(o)
    r = order_to_ranking(d, o)
    println(r)
    o1 = ranking_to_order(d, r)
    println(o1)
    return all(o .== o1)
end