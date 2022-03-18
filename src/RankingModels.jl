module RankingModels

using Distributions
using Random

import Base: length

export 
    PlackettLuce, 
    test_rand

include("PlackettLuce.jl")

end # module
