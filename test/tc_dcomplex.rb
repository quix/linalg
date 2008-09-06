#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

require 'linalg/dcomplex'

class TestDComplex < Test::Unit::TestCase
   def test_basic
      ($count*10).times {
         a = DComplex.new(1,2)
         b = DComplex.new(3,4)
         c = a + b
         assert_close(c, DComplex.new(4, 6)) ;
         
         c = a - b
         assert_close(c, DComplex.new(-2, -2)) ;
         
         c = a*b
         assert_close(c, DComplex.new(-5, 10)) ;
         
         c = a/b
         d = (a*b.conj)/(b.real*b.real + b.imag*b.imag)
         assert_close(c, d)
         
         c = DComplex.new(2,0)
         assert_close(c, DComplex.new(2, 0))
         
         c = a*2
         assert_close(c, DComplex.new(2, 4))
         
         c = 2*a
         assert_close(c, DComplex.new(2, 4))
      }
   end
end
