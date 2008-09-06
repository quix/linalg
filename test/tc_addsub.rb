#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestAddSub < Test::Unit::TestCase
   def test_addsub
      ($count/4).times {
         m = 1 + rand($dim)
         n = 1 + rand($dim)
         a = DMatrix.rand(m, n)
         b = DMatrix.rand(m, n)
         c = a + b
         d = DMatrix.new(m, n) { |i, j|
            a[i,j] + b[i,j]
         }

         assert_close(d, c)

         e = a.plus!(b)
         assert_close(e, c)
         assert_equal(e.object_id, a.object_id)
         
         f = a - b
         g = DMatrix.new(m, n) { |i,j|
            a[i,j] - b[i,j]
         }
         
         assert_close(g, f)

         h = a.minus!(b)
         assert_close(h, f)
         assert_equal(h.object_id, a.object_id)
      }
   end
end
