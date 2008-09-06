#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestScalars < Test::Unit::TestCase
   def test_scalars
      $count.times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         s = rand
         b = a*s
         c = DMatrix.new(a.vsize, a.hsize) { |i,j|
            a[i,j]*s
         }
         
         assert_close(b, c)
         
         d = a.clone
         e = d.postmul!(s)
         assert_close(e, b)
         assert_close(e, c)
         assert_equal(d.object_id, e.object_id)
         
         f = a.clone
         g = f.postmul!(s)
         assert_close(g, b)
         assert_close(g, c)
         assert_equal(g.object_id, f.object_id)
         
         h = a.clone
         i = a/(1.0/s)
         assert_close(i, b)
         assert_close(i, c)

         j = a.clone
         k = -a
         
         l = DMatrix.new(a.vsize, a.hsize) { |x,y|
            -a[x,y]
         }
         
         assert_close(k, l)
         
         m = j.negate!
         assert_close(m, k)
         assert_close(m, l)
         assert_equal(m.object_id, j.object_id)

         n = a.clone
         p = rand
         q = n*p
         r = p*n
         assert_close(q, r)

         t = DMatrix.rand(1 + rand($dim), 1)
         u = DMatrix.rand(t.vsize, 1)
         v = t.dot(u)
         w = 0.0 
         t.each_index { |i, j| w += t[i]*u[i] }
         assert_close(v, w)
      }
   end
      
end
