#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestMul < Test::Unit::TestCase
   def test_op
      $count.times {
         assert_close($mat_f*$mat_g, $mat_h)
         assert_close($mat_g*$mat_f, $mat_m)
      }
   end

   def test_mul
      $count.times {
         p = 1 + rand($dim)
         q = 1 + rand($dim)
         r = 1 + rand($dim)
         a = DMatrix.rand(p, q)
         b = DMatrix.rand(q, r)
         c = a*b
         assert_equal(c.vsize, p)
         assert_equal(c.hsize, r)
      }
   end

   def test_postmul_bang
      ($count/2).times {
         p = 1 + rand($dim)
         q = 1 + rand($dim)
         a = DMatrix.rand(p, q)
         b = DMatrix.rand(q, q)
         c = a*b
         d = a.postmul!(b)
         assert_close(c, d)
         assert_equal(a.object_id, d.object_id)
      }
   end

   def test_premul_bang
      ($count/2).times {
         p = 1 + rand($dim)
         a = DMatrix.rand(p, p)
         b = DMatrix.rand(p, p)
         c = a*b
         d = b.premul!(a)
         assert_close(c, d)
         assert_equal(b.object_id, d.object_id)
      }
   end

   def test_dot
      ($count/2).times {
         p = 1 + rand($dim)
         a = DMatrix.rand(p, 1)
         b = DMatrix.rand(p, 1)
         c = a.dot(b)
         d = 0.0

         a.each_index { |i, j|
            d += a[i,j]*b[i,j]
         }

         assert_close(c, d)
      }
   end
end

