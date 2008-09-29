#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestNullspace < Test::Unit::TestCase
   def test_typical
      ($count/2).times {
         begin
            a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
            assert_equal(a.hsize, a.rank + a.nullity, a)

            ns = a.nullspace(EPSILON)
            if ns
               z = a*ns
               
               # gives null vectors
               assert_close(z, DMatrix.new(z.vsize, z.hsize, 0.0))

               # is orthogonal
               assert_close(ns.t*ns, DMatrix.identity(ns.hsize))

               # check rankspace
               rs = a.rankspace(EPSILON)
               assert_close(rs.t*ns, DMatrix.new(rs.hsize, ns.hsize))
            end

            a = DMatrix.rand(n = 2 + rand($dim), n)
            ns = a.nullspace(EPSILON)
            if ns.nil?
               # make two columns equal
               c0 = rand(a.hsize)
               while (c1 = rand(a.hsize)) == c0
               end
               a.replace_column(c0, a.column(c1))
               ns2 = a.nullspace(EPSILON)
               assert_not_nil(ns2)
               assert_equal(ns2.hsize, 1)
               assert_equal(a.hsize, a.rank + a.nullity)
            end

         rescue Diverged
            puts "\nnote: divergent svd:\n#{a.inspect}"
         end
      }
   end

   def test_degenerate
      ($count/4).times {
         a = DMatrix.new(n = 2 + rand($dim), n, rand)
         assert_equal(a.rank, 1)
         assert_equal(a.nullity, n - 1)

         b = DMatrix.rand(n, 1)
         a.replace_column(rand(a.hsize), b)
         assert_equal(a.rank, 2)
         assert_equal(a.nullity, n - 2)
      }
   end
   
end
