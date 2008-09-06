#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestSVD < Test::Unit::TestCase

   def test_svd
      $count.times {
         begin
            a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
            mI = DMatrix.identity(a.vsize)
            nI = DMatrix.identity(a.hsize)
            a.svd { |u, s, vt|
               if catch(:bad) {
                     s.each_with_index { |e, i, j|
                        if i != j and e != 0.0
                           throw :bad, true 
                        end
                     }
                     throw :bad, false
                  }
                  assert_block { false }
               end
               
               assert_close(u*u.t, mI)
               assert_close(vt*vt.t, nI)
               assert_close(u*s*vt, a)

               svlist = a.singular_values
               svdlist = []
               s.diags.each { |e| svdlist << e }
               
               svlist.each_index { |i, j|
                  assert_close(svlist[i], svdlist[i])
               }
            }
         rescue Diverged
            puts "\nnote: divergent svd:\n#{a.inspect}"
         end
      }
   end
end
