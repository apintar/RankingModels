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

function test_rand()
    p = rand(Uniform(), 5)
    p = p./sum(p)
    p = [0., 0, 0.1, 0.9, 0]
    println(p)
    d = PlackettLuce(2, p)
    # x = zeros(Int64, 2, d.n)
    # rand!(d, x)
    x = rand(d, 20)
    return x
end