using POMDPs
using QuickPOMDPs


"""
    Suppose that you decide to use a particle filter with 3 particles (|ˆb| = 3)
    for approximate belief updates. The initial particle-based belief approximation
    is ˆb0 = {1,2,3}. Perform a single belief update (following Algorithm 6.3)
    with a = 4, o = 1, using G from (1) in Alg 6.3, line 5. Use the following
    outcomes for the random parts of the algorithm:

        • Inline 4: s1 =1,s2 =2,s3 =3
        • Inline 5,thevalues of v input to G are: v1 =0.01,v2 =0.32,v3 =0.74.
        • In line 8, select the new states however you would like.
"""


tiger = QuickPOMDP(
    function (s, a, v=rand())
        ov = rand()
        v < 0.05 ? sp = mod(s,3)+1 : sp = s
        a == 4 ? r = 0.0 : a == s ? r = -100.0 : r = 10.0
        ov > 0.8 ? o = sp : o = rand(setdiff(Set([1,2,3]), sp))
        return (sp=sp, r=r, o=o)
    end,

    states = [1, 2, 3],
    actions = [1, 2, 3, 4],
    observations = [1, 2, 3]
);

function UpdateBelief(b=(1,2,3), a=4,o=1) # starting with b_0=(1,2,3)
    Gp(s, v) = v < 0.05 ? mod(s,3)+1 : s
    # w(si, o ) = o == si ? 0.8 : 0.1
    # bp = (0,0,0)
    s = (1, 2, 3)
    v = (0.01, 0.32, 0.74)
    sp = [Gp(s[i], v[i]) for i in 1:3]
    #wi = [w(si[i], 0) for i in 1:3]
    bp = [rand([2,2,3]), rand([2,2,3]), rand([2,2,3])]
    return bp
end

b1 = UpdateBelief();
