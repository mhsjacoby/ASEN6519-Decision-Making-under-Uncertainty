

S = [:healthy, :in_situ_cancer, :invasive_cancer, :death]
A = [:wait, :test, :treat]
O = [:positive, :negative]



function T(s, a, sp)
    if s == :healthy
        if sp == :in_situ_cancer
            return 0.02
        elseif sp == :healthy
            return 0.98
        end
    elseif s == :in_situ_cancer
        if a == :treat
            if sp == :healthy
                return 0.6
            elseif sp == :in_situ_cancer
                return 0.4
            end
        else
            if sp == :invasive_cancer
                return 0.1
            elseif sp == :in_situ_cancer
                return 0.9
            end
        end
    elseif s == :invasive_cancer
        if a == :treat
            if sp == :healthy
                return 0.2
            elseif sp == :death
                return 0.2
            elseif sp == :invasive_cancer
                return 0.6
            end
        else
            if sp == :death
                return 0.6
            elseif sp == :invasive_cancer
                return 0.4
            end
        end
    end
    if s == sp
        return 1.0
    else
        return 0.0
    end
end


function Z(a, sp, o)
    if a == :test
        if sp == :healthy
            if o == :positive
                return 0.05
            else
                return 0.95
            end
        elseif sp == :in_situ_cancer
            if o == :positive
                return 0.8
            else
                return 0.2
            end
        elseif sp == :invasive_cancer
            if o == :positive
                return 1.0
            else
                return 0.0
            end
        end
    elseif a == :treat
        if sp == :in_situ_cancer || sp == :invasive_cancer
            if o == :positive
                return 1.0
            else
                return 0.0
            end
        end
    end
    if o == :negative
        return 1.0
    else
        return 0.0
    end
end

function R(s, a)
    if s == :death
        return 0.0
    elseif a == :wait
        return 1.0
    elseif a == :test
        return 0.8
    elseif a == :treat
        return 0.1
    end
end


# m = DiscreteExplicitPOMDP(S, A, O, T, Z, R, 0.99,
#                             Deterministic(:healthy),
#                             terminals=Set([:death]));
