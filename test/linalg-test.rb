#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'fileutils'

$LOAD_PATH.unshift "../ext/linalg"
$LOAD_PATH.unshift "../ext/lapack"
$LOAD_PATH.unshift "../lib"

require 'linalg/dmatrix'
require 'test/unit'

include Linalg
include Linalg::Exception

$count = 100
$dim = 100

EPSILON = 1e-8
DMatrix.default_epsilon = EPSILON

class Float
   def within(epsilon, other = 0.0)
      (self - other).abs < epsilon
   end

   def =~(other)
      self.within(EPSILON, other)
   end

   alias_method :inspect2, :inspect
end

class Test::Unit::TestCase
   def assert_close(a, b)
      assert_block {
         a.within(EPSILON, b)
      }
   end
end

$mat_f = DMatrix.rows [
   [1.0, 2.0 ,3.0 ,4.0],
   [5.0, 6.0 ,7.0 ,8.0],
]

$mat_g = DMatrix.rows [
   [1.0, 5.0],
   [2.0, 6.0],
   [3.0, 7.0],
   [4.0, 8.0],
]

$mat_h = DMatrix.rows [
   [30.0, 70.0],
   [70.0, 174.0],
]

$mat_m = DMatrix.rows [
   [ 26.0, 32.0, 38.0, 44.0 ],
   [ 32.0, 40.0, 48.0, 56.0 ],
   [ 38.0, 48.0, 58.0, 68.0 ],
   [ 44.0, 56.0, 68.0, 80.0 ],
]

