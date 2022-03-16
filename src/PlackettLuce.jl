struct PlackettLuce{S<:Integer, T<:Real} <: DiscreteMultivariateDistribution
    K::S
    n::S
    p::Vector{T}
    function PlackettLuce{S, T}(K::S, n::S, p::Vector{T}) where {S<:Integer, T<:Real}
        check1 = (n > 0)
        check2 = (K >= n)
        check3 = isprobvec(p)
        check4 = length(p) == K
        check1 && check2 && check3 && check4 ? new(K, n, p) : error("invalid PlackettLuce parameters")
    end
end

function PlackettLuce(K::S, n::S, p::Vector{T}) where {S<:Integer, T<:Real}
    PlackettLuce{S, T}(K, n, p)
end

function PlackettLuce(n::S, p::Vector{T}) where {S<:Integer, T<:Real}
    PlackettLuce(promote(length(p), n), p)
end

test(a::T) where {T<:Real} = println(a+1)
