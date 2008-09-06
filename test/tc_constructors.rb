#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

class TestConstructors < Test::Unit::TestCase

   def test_brackets_rows_columns
      ($count/10).times {
         m = 1 + rand($dim)
         n = 1 + rand($dim)

         a = Array.new(m) { Array.new(n) { rand } }

         DMatrix[*a].each_with_index { |e, i, j|
            assert_close(e, a[i][j])
         }

         DMatrix.rows(a).each_with_index { |e, i, j|
            assert_close(e, a[i][j])
         }
         
         DMatrix.columns(a).each_with_index { |e, i, j|
            assert_close(e, a[j][i])
         }
      }
   end

   def test_bad_array
      $count.times {
         m = 4 + rand($dim)
         n = 4 + rand($dim)
         a = Array.new(m) { Array.new(n) { rand } }
         k = rand(a.size)
         a[k].slice!(rand(a[k].size), 1)
         assert_raises(RuntimeError) { DMatrix[*a] }
         assert_raises(RuntimeError) { DMatrix.rows(a) }
         assert_raises(RuntimeError) { DMatrix.columns(a) }

         assert_raises(RuntimeError) { DMatrix["foo"] }
         assert_raises(RuntimeError) { DMatrix[File] }
         assert_raises(RuntimeError) { DMatrix.rows("foo") }
         assert_raises(RuntimeError) { DMatrix.rows(File) }
         assert_raises(RuntimeError) { DMatrix.columns("foo") }
         assert_raises(RuntimeError) { DMatrix.columns(File) }
      }
   end

   def test_dim_error
      assert_raises(DimensionError) { DMatrix.new(1, -1) }
      assert_raises(DimensionError) { DMatrix.new(-1, 1) }
      assert_raises(DimensionError) { DMatrix.new(-1, -1) }
      assert_raises(DimensionError) { DMatrix.identity(-1) }
      assert_raises(DimensionError) { DMatrix.diagonal(-1, 0.0) }
      assert_raises(DimensionError) { DMatrix.diagonal(-1) { } }
      assert_raises(DimensionError) { DMatrix.diagonal([]) }
      assert_raises(DimensionError) { DMatrix.rand(1, -1) }
      assert_raises(DimensionError) { DMatrix.rand(-1, 1) }
      assert_raises(DimensionError) { DMatrix.rand(-1, -1) }
   end

   def test_identity
      ($count/10).times {
         m = DMatrix.identity(1 + rand($dim))
         m.each_with_index { |e, i, j|
            assert_block { 
               if i == j
                  e =~ 1.0
               else
                  e == 0.0
               end
            }
         }
      }
   end
   
   def test_new
      ($count/10).times {
         a = DMatrix.new(1 + rand($dim), 1 + rand($dim))
         assert_block { a.elems.all? { |e| e == 0.0 } }
         
         a = DMatrix.new(1 + rand($dim), 1 + rand($dim), s = rand)
         assert_block { a.elems.all? { |e| e =~ s } }

         p = rand
         q = rand
         a = DMatrix.new(1 + rand($dim), 1 + rand($dim)) { |i,j|
            p*i + q*j
         }
         a.each_with_index { |e, i, j|
            assert_block { e =~ p*i + q*j }
         }
      }
   end

   def test_diagonal
      ($count/10).times {
         n = 1 + rand($dim)
         a = Array.new(n) { rand }
         v = DMatrix.columns([a])

         DMatrix.diagonal(a).each_with_index { |e, i, j|
            assert_block {
               if i == j
                  e =~ a[i]
               else
                  e == 0.0
               end
            }
         }

         DMatrix.diagonal(v).each_with_index { |e, i, j|
            assert_block {
               if i == j
                  e =~ v[i]
               else
                  e == 0.0
               end
            }
         }

         DMatrix.diagonal(n, s = rand).each_with_index { |e, i, j|
            assert_block("expected #{i}, #{j} to be #{s}, not #{e}") {
               if i == j
                  e =~ s
               else
                  e == 0.0
               end
            }
         }

         DMatrix.diagonal(n){|i|a[i]}.each_with_index { |e, i, j|
            assert_block {
               if i == j
                  e =~ a[i]
               else
                  e == 0.0
               end
            }
         }

      }
   end

end

