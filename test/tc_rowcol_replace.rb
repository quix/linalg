#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestRowColReplace < Test::Unit::TestCase
   def test_column_replace
      $count.times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         b = a.clone
         v = DMatrix.rand(a.vsize, 1)
         p = rand(a.hsize)
         a.replace_column(p, v)
         assert_block { a.column(p).within(0.0, v) }
         a.each_with_index { |e,i,j|
            if j == p
               e.within(EPSILON, v[i])
            else
               e.within(0.0, b[i,j])
            end
         }
         
         assert_raises(IndexError) { a.replace_column(a.hsize, v) }
         assert_raises(IndexError) { a.replace_column(-1, v) }
         assert_raises(TypeError) { a.replace_column(File, v) }
         assert_raises(TypeError) { a.replace_column("foo", v) }
         assert_raises(TypeError) { a.replace_column(0, File) }
         assert_raises(TypeError) { a.replace_column(0, "foo") }
         assert_raises(DimensionError) {
            a.replace_column(0, DMatrix.new(a.vsize + 1, 1))
         }
         assert_raises(DimensionError) {
            a.replace_column(0, DMatrix.new(a.vsize, 2))
         }
      }
   end

   def test_row_replace
      $count.times {
         a = DMatrix.rand(1 + rand($dim), 1 + rand($dim))
         b = a.clone
         v = DMatrix.rand(1, a.hsize)
         p = rand(a.vsize)
         a.replace_row(p, v)
         assert_block { a.row(p).within(0.0, v) }
         a.each_with_index { |e,i,j|
            if j == p
               e.within(EPSILON, v.t[j])
            else
               e.within(0.0, b[i,j])
            end
         }
         
         assert_raises(IndexError) { a.replace_row(a.vsize, v) }
         assert_raises(IndexError) { a.replace_row(-1, v) }
         assert_raises(TypeError) { a.replace_row(File, v) }
         assert_raises(TypeError) { a.replace_row("foo", v) }
         assert_raises(TypeError) { a.replace_row(0, File) }
         assert_raises(TypeError) { a.replace_row(0, "foo") }
         assert_raises(DimensionError) {
            a.replace_row(0, DMatrix.new(1, a.hsize + 1))
         }
         assert_raises(DimensionError) {
            a.replace_row(0, DMatrix.new(2, a.hsize))
         }
      }
   end
end

