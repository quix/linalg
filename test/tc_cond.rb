#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestCond < Test::Unit::TestCase
   def test_cond
      $count.times {
         n = 1 + rand($dim)
         a = DMatrix.rand(n, n)
         est = a.cond_est_1
         actual = a.norm_1*(a.inv.norm_1)
         
         # I don't know what to put here.
         # within order of magnitude ?

         err = est/actual
         assert_block("#{err}") { err < 10.0 and err > 0.1 }
         
         est = a.cond_est_inf
         actual = a.norm_inf*(a.inv.norm_inf)

         assert_block("#{err}") { err < 10.0 and err > 0.1 }
      }
   end
   
   def test_degen
      $count.times {
         a = DMatrix.rand(1,1)
         assert_close(a.cond_est_1, 1.0)
         assert_close(a.cond_est_inf, 1.0)
      }
   end

   def test_raises
      assert_raises(DimensionError) { DMatrix.new(4, 5).cond_est_1 }
      assert_raises(DimensionError) { DMatrix.new(5, 4).cond_est_1 }
      assert_raises(DimensionError) { DMatrix.new(4, 5).cond_est_inf }
      assert_raises(DimensionError) { DMatrix.new(5, 4).cond_est_inf }
   end
end
