#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestCholesky < Test::Unit::TestCase
   def test_cholesky
      $count.times {
         n = 1 + rand($dim)
         a = DMatrix.rand(n, n)
         a = a.t*a
         b = a.chol
         assert_close(b.t*b, a)
         assert_block {
            catch(:result) {
               b.each_with_index { |e, i, j|
                  if i > j and e != 0.0
                     throw :result, false
                  end
               }
               throw :result, true
            }
         }
      }
   end
end
