# define transition probabilities
function T(s, a, sp)
   if s == :health
       if sp == :isCancer
           return 0.02
       elseif sp == s
           return 0.98
       else
           return 0.0
       end

   elseif s == :isCancer
       if a == :treat
           if sp == :healthy
               return 0.6
           elseif sp == :isCancer
               return 0.4
           else
               return 0.0
           end
       elseif a != :treat
           if sp == :isCancer
               return 0.9
           elseif sp == :invCancer
               return 0.1
           else
               return 0.0
           end
       else
           return 0.0
       end
   elseif s == :invCancer
       if a == :treat
           if sp == :healthy
               return 0.2
           elseif sp == :death
               return 0.2
           elseif sp == :invCancer
               return 0.6
           else
               return 0.0
           end
       elseif a != :treat
           if sp == :death
               return 0.6
           elseif sp == :invCancer
               return 0.4
           else
               return 0.0
           end
       end
   elseif s == :death
       if a in A
           if sp == :death
               return 1.0
           else
               return 0.0
           end
       else
           return 0.0
       end
   end
end
