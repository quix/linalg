#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestLU < Test::Unit::TestCase
   def test_lu
      $count.times { 
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         
         p, l, u = a.lu
         
         assert_close(p.det.abs, 1.0)
         assert_close(p*l*u, a)
         
         assert_block {
            catch(:result) {
               u.each_lower_with_index { |e, i, j|
                  throw :result, false unless e == 0.0
               }
               throw :result, true
            }
         }

         assert_block {
            catch(:result) {
               l.each_upper_with_index { |e, i, j|
                  throw :result, false unless e == 0.0
               }
               throw :result, true
            }
         }
         
         a.lu!

         assert_block {
            catch(:result) {
               a.each_with_index { |e, i, j|
                  unless e =~ (i > j ? l[i,j] : u[i,j])
                     throw :result, false 
                  end
               }
               throw :result, true
            }
         }
      }
   end
end
