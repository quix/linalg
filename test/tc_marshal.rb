#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestMarshal < Test::Unit::TestCase
   def test_marshal
      ($count*5).times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim)) ;
         b = Marshal.load(Marshal.dump(a)) ;
         assert_block { a.within(0.0, b) }
      }
   end

   def test_marshal_big
      a = DMatrix.rand(1 + rand(10*$dim), 1 + rand(10*$dim)) ;
      b = Marshal.load(Marshal.dump(a)) ;
      assert_block { a.within(0.0, b) }
   end
end
