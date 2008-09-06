#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestAccess < Test::Unit::TestCase

   def test_access
      a = [
         [1,2,3,4],
         [5,6,7,8],
      ]

      f = DMatrix.rows a
      
      assert_equal(f.hsize, 4)
      assert_equal(f.vsize, 2)

      assert_close(f[1,0], 5.0)
      assert_close(f[0,1], 2.0)
      assert_close(f[0,3], 4.0)
      assert_close(f[1,3], 8.0)

      assert_raises(IndexError) { f[2,0] }
      assert_raises(IndexError) { f[0,4] }
      assert_raises(IndexError) { f[2,4] }
      assert_raises(IndexError) { f[-1,0] }
      assert_raises(IndexError) { f[0,-1] }
      assert_raises(IndexError) { f[-1,-1] }

      assert_raises(DimensionError) { DMatrix.new(-1,4) }
      assert_raises(DimensionError) { DMatrix.new(1,-4) }
      assert_raises(DimensionError) { DMatrix.new(-1,-4) }

      assert_close(f.row(0), DMatrix.rows([a[0]]))
      assert_close(f.row(1), DMatrix.rows([a[1]]))
      
      assert_raises(IndexError) { f.row(2) }
      
      assert_close(f.column(0), DMatrix.columns([[1,5]]))
      assert_close(f.column(3), DMatrix.columns([[4,8]]))

      assert_raises(IndexError) { f.column(4) }

      b = [
         [1,5],
         [2,6],
         [3,7],
         [4,8],
      ]
      
      g = DMatrix.rows b
      
      assert_close(f.transpose, g)
      assert_close(f, g.transpose)

      assert_close(f.column(0), g.row(0).transpose)
      assert_close(f.row(0), g.column(0).transpose)
      assert_close(f.column(1), g.row(1).transpose)
      assert_close(f.row(1), g.column(1).transpose)
      
      assert_raises(DimensionError) { f.column(0) =~ g.row(0) }
      assert_raises(DimensionError) { f.row(0) =~ g.column(0) }
      assert_raises(DimensionError) { f.column(1) =~ g.row(1) }
      assert_raises(DimensionError) { f.row(1) =~ g.column(1) }

      h = DMatrix.columns a
      assert_close(g, h)
   end
end

