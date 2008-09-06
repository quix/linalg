#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestInverse < Test::Unit::TestCase
   def test_inverse
      ($count/5).times {
         dim = 2 + rand($dim)
         a = DMatrix.rand(dim, dim)
         iden = DMatrix.identity(dim)
         assert_close(a*a.inverse, iden)
         assert_close(a.inverse*a, iden)
      }
   end

   def test_singular
      ($count/5).times {
         a = DMatrix[[1,1],[2,2]]
         assert_raises(SingularMatrix) { a.inverse }
         assert_raises(SingularMatrix) { a.inverse! }
      }

      ($count/2).times {
         a = DMatrix.rand(n = 2 + rand($dim), n)

         # introduce a singularity: two rows the same
         r0 = rand(a.vsize)
         while (r1 = rand(a.vsize)) == r0 ; end
         a.map_with_index! { |e, i, j|
            (i == r0 || i == r1) ? 1.0 : e
         }
         
         assert_raises(SingularMatrix) { a.inverse }
         assert_raises(SingularMatrix) { a.inverse! }
      }
   end

   def test_raises
      assert_raises(DimensionError) { DMatrix.new(2,3).inv }
      assert_raises(DimensionError) { DMatrix.new(3,2).inv }
   end
end
