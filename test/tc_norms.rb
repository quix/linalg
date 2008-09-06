#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestNorms < Test::Unit::TestCase
   def test_norm_1
      ($count/5).times {
         m = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         norm = m.columns.map { |col|
            col.elems.inject(0.0) { |acc, e| acc + e.abs }
         }.sort[-1]
         assert_close(norm, m.norm_1)
      }
   end

   def test_norm_inf
      ($count/5).times {
         m = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         norm = m.rows.map { |row|
            row.elems.inject(0.0) { |acc, e| acc + e.abs }
         }.sort[-1]
         assert_close(norm, m.norm_inf)
      }
   end

   def test_norm_f
      ($count/5).times {
         m = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         fnorm = Math.sqrt(m.elems.inject(0.0) { |acc, e| acc + e*e })
         assert_close(fnorm, m.norm_f)
      }
   end

   # not a norm, but here anyway
   def test_maxabs
      ($count/5).times {
         m = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         max = m.map { |e| e.abs }.to_a.flatten.sort[-1]
         assert_close(max, m.maxabs)
      }
   end

end
