#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestQR < Test::Unit::TestCase
   def test_qr
      $count.times {
         m = 1 + rand($dim)
         n = 1 + rand($dim)
         a = DMatrix.rand(m, n)
         q, r = a.qr
         assert_close(a, q*r)
         assert_close(q*q.t, DMatrix.identity(q.vsize))
         assert_block {
            catch(:result) {
               r.each_lower_with_index { |e, i, j|
                  if e != 0.0
                     throw :result, false
                  end
               }
               throw :result, true
            }
         }
      }
   end
end

