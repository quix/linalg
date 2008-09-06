#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestSchur < Test::Unit::TestCase
   def test_schur
      ($count/2).times {
         n = 1 + rand($dim)
         a = DMatrix.rand(n, n)
         z, t, re, im = a.schur
         assert_close(a, z*t*z.t)
         assert_close(z*z.t, DMatrix.identity(n))
         t.each_with_index { |e, i, j|
            if i == j + 1 and e != 0.0
               assert_equal(t[i - 1, j - 1], 0.0) if j - 1 > 0
               assert_equal(t[i + 1, j + 1], 0.0) if i + 1 < n
            elsif i >= j + 2
               assert_equal(e, 0.0)
            end
         }

         re2, im2 = a.eigenvalues
         re = DMatrix.rows [re.to_a.flatten.sort]
         re2 = DMatrix.rows [re2.to_a.flatten.sort]
         im = DMatrix.rows [im.to_a.flatten.sort]
         im2 = DMatrix.rows [im2.to_a.flatten.sort]
         assert_close(re, re2)
         assert_close(im, im2)
      }
   end
end

