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

function Distributions._rand!(rng::AbstractRNG, d::PlackettLuce, x::AbstractVector{T}) where {T<:Integer}
    p = copy(d.p)
    x_choose = collect(1:d.K)
    for i in 1:d.n
        choice_idx = rand(rng, Categorical(p))
        x[i] = x_choose[choice_idx]
        deleteat!(p, choice_idx)
        p = p./sum(p)
        deleteat!(x_choose, choice_idx)
    end
    return x
end

function test_rand(;p=nothing, K=5, nsamp=10000)
    isnothing(p) && (p = rand(Uniform(), K))
    p = p./sum(p)
    d = PlackettLuce(5, p)
    x = rand(d, nsamp)
    y = counts(x[1, :])./nsamp
    return (abs.(p - y)./p)*100
end