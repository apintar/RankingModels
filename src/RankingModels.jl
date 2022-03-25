module RankingModels

using Distributions
using Random
using StatsBase

export 
    PlackettLuce, 
    order_to_ranking,
    ranking_to_order,
    test_rand,
    test_ro_trans

include("PlackettLuce.jl")

end # module
