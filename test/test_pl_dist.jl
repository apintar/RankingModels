using Distributions

function test_rand(;p=nothing, K=5, nsamp=10000)
    isnothing(p) && (p = rand(Uniform(), K))
    p = p./sum(p)
    d = PlackettLuce(p)
    o = rand(d, nsamp)
    display(o[:, 1:5])
    y = counts(o[1, :], 1:length(p))./nsamp
    return (abs.(p - y)./p)*100
end

function test_part_rand(;p=nothing, K=5, n=3, nsamp=10000)
    isnothing(p) && (p = rand(Uniform(), K))
    p = p./sum(p)
    d = PlackettLuce(p)
    o = part_rand(d, n, nsamp)
    display(o[:, 1:5])
    y = counts(o[1, :], 1:length(p))./nsamp
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