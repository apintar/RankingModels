struct PlackettLuce{T<:Real, TV<:AbstractVector{T}} <: DiscreteMultivariateDistribution
    K::Int
    n::Int
    p::TV
    function PlackettLuce(K::Int, n::Int, p::TV) where {T<:Real, TV<:AbstractVector{T}}
        check1 = (n > 0)
        check2 = (K >= n)
        check3 = isprobvec(p)
        check4 = length(p) == K
        check1 && check2 && check3 && check4 ? new{T, TV}(K, n, p) : error("invalid PlackettLuce parameters")
    end
end

function PlackettLuce(n::Int, p::TV) where {T<:Real, TV<:AbstractVector{T}}
    check1 = (n > 0)
    check2 = isprobvec(p)
    check3 = length(p) >= n
    check1 && check2 && check3 ? PlackettLuce(length(p), n, p) : error("invalid PlackettLuce parameters")
end
