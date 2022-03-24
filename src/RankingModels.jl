module RankingModels

using Distributions
using Random
using StatsBase

export 
    PlackettLuce, 
    test_rand

include("PlackettLuce.jl")

end # module
