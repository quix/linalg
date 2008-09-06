#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestTranspose < Test::Unit::TestCase
   def test_transpose
      $count.times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         b = a.transpose
         c = DMatrix.new(a.hsize, a.vsize) { |i,j| a[j,i] }
         
         assert_close(b, c)
      }
   end

   def test_transpose_bang
      $count.times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         c = DMatrix.new(a.hsize, a.vsize) { |i,j| a[j,i] }
         a.transpose!

         assert_close(a, c)
      }
   end

   def test_vector_transpose_bang
      $count.times {
         a = DMatrix.rand(1 + rand($dim), 1)
         c = DMatrix.new(a.hsize, a.vsize) { |i,j| a[j,i] }
         a.transpose!

         assert_close(a, c)
      }
   end
end
