#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestMinors < Test::Unit::TestCase
   def test_minor
      ($count/3).times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))

         vsize = 1 + rand(a.vsize)
         hsize = 1 + rand(a.hsize)
         
         if vsize == a.vsize 
            mi = 0
         else
            mi = rand(a.vsize - vsize)
         end
         
         if hsize == a.hsize
            mj = 0
         else
            mj = rand(a.hsize - hsize)
         end

         m = a.minor(mi, mj, vsize, hsize)

         m.each_with_index { |e, i, j|
            assert_close(e, a[mi + i, mj + j])
         }

         m.map! { rand }
         b = a.clone
         b.replace_minor(mi, mj, m)
         b.each_with_index { |e, i, j|
            if true and
                  i >= mi and
                  i < mi + m.vsize and
                  j >= mj and
                  j < mj + m.hsize
               assert_close(e, b[i,j])
            else
               assert_close(a[i,j], b[i,j])
            end
         }
      }
   end

   def test_raises
      ($count/2).times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         assert_raises(DimensionError) { a.minor(0,0, 0, 1) }
         assert_raises(DimensionError) { a.minor(0,0, 1, 0) }
         assert_raises(DimensionError) { a.minor(0,0, 0, -1) }
         assert_raises(DimensionError) { a.minor(0,0, -1, 0) }
         assert_raises(DimensionError) { a.minor(0,0, -1, -1) }
         assert_raises(IndexError) { a.minor(0, 0, a.vsize + 1, 1) }
         assert_raises(IndexError) { a.minor(0, 0, 1, a.hsize + 1) }
         assert_raises(IndexError) { a.minor(a.vsize, 0, 1, 1) }
         assert_raises(IndexError) { a.minor(0, a.hsize, 1, 1) }
         assert_raises(IndexError) { a.minor(1, 0, a.vsize, 1) }
         assert_raises(IndexError) { a.minor(0, 1, 1, a.hsize) }
         assert_nothing_raised { a.minor(a.vsize - 1, 0, 1, 1) }
         assert_nothing_raised { a.minor(0, a.hsize - 1, 1, 1) }
         assert_nothing_raised { a.minor(0, 0, 1, 1) }
         assert_nothing_raised { a.minor(a.vsize - 1, a.hsize - 1, 1, 1) }
      }
   end
end
