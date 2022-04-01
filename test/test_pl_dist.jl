function test_rand(;p=nothing, K=5, nsamp=10000)
    isnothing(p) && (p = rand(Uniform(), K))
    p = p./sum(p)
    d = PlackettLuce(5, p)
    x = rand(d, nsamp)
    y = counts(x[1, :])./nsamp
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