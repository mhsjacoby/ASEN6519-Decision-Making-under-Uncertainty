## transition and observation dynamics for DMU HW 5 Problem 2


function T(s, a, sp)
    if s == :healthy
        if sp == :in_situ
            return 0.02
        elseif sp == s
            return 0.98
        else
            return 0.0
        end
    elseif s == :in_situ
        if a == :treat
            if sp == :healthy
                return 0.60
            elseif sp == s
                return 0.40
            else
                return 0.0
            end
        else #a == :test || a == :wait
            if sp == :invasive
                return 0.10
            elseif sp == s
                return 0.90
            else
                return 0.0
            end
        end
    elseif s == :invasive
        if a == :treat
            if sp == :healthy
                return 0.20
            elseif sp == :death
                return 0.20
            elseif sp == s
                return 0.60
            else
                return 0.0
            end
        else
            if sp == :death
                return 0.60
            elseif sp == s
                return 0.40
            else
                return 0.0
            end
        end
    else
        if sp == s# s == :death
            return 1.0
        else
            return 0.0
        end
    end
end










function Z(a, sp, o)
    if a == :test
        if sp == :healthy
            if o == :pos
                return 0.05
            else
                return 0.95
            end
        elseif sp == :in_situ
            if o == :pos
                return 0.80
            else
                return 0.20
            end
        else
            if o == :pos
                return 1.0
            else
                return 0.0
            end
        end
    elseif a == :treat
        if sp == :in_situ || sp == :invasive
            if o == :pos
                return 1.0
            else
                return 0.0
            end
        else
            if o == :pos
                return 0.0
            else
                return 1.0
            end
        end
    else #a == :wait
        if o == :pos
            return 0.0
        else
            return 1.0
        end
    end
end



function R(s, a)
    if s == :death
        return 0.0
    elseif a == :wait
        return 1.0
    elseif a == :test
        return 0.80
    else
        return 0.10
    end
end
