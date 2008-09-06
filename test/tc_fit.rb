#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestFit < Test::Unit::TestCase
   def test_correspondence_principle
      count = 0
      loop {
         n = 1 + rand($dim)
         nrhs = 1 + rand($dim)
         a = DMatrix.rand(n, n)

         next if a.singular?(1e-4)
         count += 1

         b = DMatrix.rand(n, nrhs)
         x0 = DMatrix.solve(a, b)

         begin
            [:fit].each { |f|
               x, = DMatrix.send(f, a, b)
               assert_close(x, x0)
            }
         rescue Diverged
         end

         break if count == $count
      }
   end

   def test_general
      ($count/10).times {
         m = 1 + rand($dim)
         n = 1 + rand($dim)
         nrhs = 1 + rand($dim)
         a = DMatrix.rand(m, n)
         
         [:fit].each { |f|
            b = DMatrix.rand(m, nrhs)
            
            x, sv = DMatrix.send(f, a, b)
            best = (a*x - b).norm
            
            ($count*2).times {
               x = DMatrix.rand(n, nrhs)
               assert_block { best < (a*x - b).norm }
            }
            
            if sv
               sv2 = a.sv
               sv.elems.each_with_index { |e, i| 
                  assert_close(e, sv2[i])
               }
            end
         }
      }
   end

end

