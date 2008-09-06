#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestSolve < Test::Unit::TestCase

   def test_solve
      $count.times {
         a = DMatrix.rand(n = 1 + rand($dim), n)
         b = DMatrix.rand(a.vsize, 1 + rand($dim))

         begin
            x = DMatrix.solve(a, b)
            assert_close(a*x, b)
         rescue SingularMatrix
            assert_block { true }
         end
      }
   end

   def test_solve_bang
      $count.times {
         a0 = DMatrix.rand(n = 1 + rand($dim), n)
         b0 = DMatrix.rand(a0.vsize, 1 + rand($dim))

         a = a0.clone
         b = b0.clone

         begin
            x = Linalg::DMatrix.solve!(a, b)
            assert(b == x)
            assert(b.object_id == x.object_id)
            assert_close(a0*x, b0)
         rescue SingularMatrix
            assert_block { true }
         end
      }
   end

   def test_singular
      a = DMatrix[[1,1],[2,2]]
      b = DMatrix.columns [[3,3]]
      assert_raises(SingularMatrix) { DMatrix.solve(a,b) }

      ($count/2).times {
         a = DMatrix.rand(n = 2 + rand($dim), n)
         b = DMatrix.rand(a.vsize, 1 + rand($dim))

         # introduce a singularity: two rows the same
         r0 = rand(a.vsize)
         while (r1 = rand(a.vsize)) == r0 ; end
         a.map_with_index! { |e, i, j|
            (i == r0 || i == r1) ? 1.0 : e
         }
         
         assert_raises(SingularMatrix) { DMatrix.solve(a,b) }
      }
   end
end
