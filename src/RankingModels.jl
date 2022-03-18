module RankingModels

using Distributions
using Random

import Base: length

export 
    PlackettLuce, 
    ncategories,
    test_rand

include("PlackettLuce.jl")

end # module
