#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestDet < Test::Unit::TestCase
   def test_1x1
      $count.times {
         a = DMatrix.rand(1,1)
         assert_close(a[0,0], a.det)
      }
   end

   def test_2x2
      a = DMatrix[[1,0],[0,1]]
      assert_close(a.det, 1.0)
      a = DMatrix[[0,1],[1,0]]
      assert_close(a.det, -1.0)

      ($count*10).times {
         a = DMatrix.rand(2,2)
         det = a[0,0]*a[1,1] - a[0,1]*a[1,0]
         assert_close(det, a.det)
      }
   end

   def test_3x3
      ($count*10).times {
         a = DMatrix.rand(3,3)
         det =
            a[0,0]*(a[1,1]*a[2,2] - a[1,2]*a[2,1]) -
            a[0,1]*(a[1,0]*a[2,2] - a[1,2]*a[2,0]) +
            a[0,2]*(a[1,0]*a[2,1] - a[1,1]*a[2,0])
         assert_close(det, a.det)
      }
   end

   def test_nxn
      ($count*10).times {
         n = 2 + rand(20)  # error too big for greater dim
         a = DMatrix.rand(n, n)
         det = 0.0 

         n.times { |k|
            sign = k % 2 == 0 ? 1.0 : -1.0
            if k == 0 
               det += sign*a[0,k]*a.minor(1, 1, n - 1, n - 1).det
            elsif k == n - 1
               det += sign*a[0,k]*a.minor(1, 0, n - 1, n - 1).det
            else
               left_minor = a.minor(1, 0, n - 1, k)
               right_minor = a.minor(1, k + 1, n - 1, n - k - 1)
               
               minor = DMatrix.new(n - 1, n - 1)
               minor.replace_minor(0, 0, left_minor)
               minor.replace_minor(0, k, right_minor)
               
               det += sign*a[0,k]*minor.det
            end
         }
         
         assert_close(det, a.det)
      }
   end

   def test_raises
      assert_raises(DimensionError) { DMatrix.rand(4,5).det }
      assert_raises(DimensionError) { DMatrix.rand(5,4).det }
   end
end
