#= 
These are non-parameterized versions of the PlackettLuce composite type
(distribution).  Would need to other outside constructors for convenience for
types of p other than Float64.  Changed to template instead.
=#

struct PlackettLuce <: DiscreteMultivariateDistribution
    K::Int
    n::Int
    p::Vector{Float64}
    function PlackettLuce(K::Int, n::Int, p::Vector{Float64})
        check1 = (n > 0)
        check2 = (K >= n)
        check3 = isprobvec(p)
        check4 = length(p) == K
        check1 && check2 && check3 && check4 ? new(K, n, p) : error("invalid PlackettLuce parameters")
    end
end

function PlackettLuce(K::Int, n::Int, p::Vector{Int64})
    pf = convert(Vector{Float64}, p)
    PlackettLuce(K, n, pf)
end
