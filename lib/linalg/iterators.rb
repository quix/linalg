#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   
   #
   # <tt>Enumerable</tt>s and <tt>Enumerable</tt>-like
   # methods for matrices.
   #
   # For blocks which yield <tt>i,j</tt> indexes, the visitation is
   # always in column-major order -- that is, +i+ changes faster than +j+.
   #
   # To visit in row-major order, one would say
   #   m.rows.each_with_index { |row, i|
   #      row.elems.each_with_index { |e, j| 
   #         # e == m[i,j]
   #      }
   #   }
   #
   module Iterators

      #
      # Common +Enumerable+ for matrices
      #
      class MatrixEnum
         include Enumerable
         def initialize(m)
            @m = m
         end
      end

      #
      # This class doesn't do much except +yield+ matrix elements.
      #
      class DiagEnum < MatrixEnum
         def each
            min = @m.hsize < @m.vsize ? @m.hsize : @m.vsize
            min.times { |i|
               yield @m[i,i]
            }
            @m
         end
      end

      #
      # This class doesn't do much except +yield+ matrix elements.
      #
      class ElemEnum < MatrixEnum
         def each
            (0...@m.hsize).each { |j|
               (0...@m.vsize).each { |i|
                  yield @m[i,j]
               }
            }
            @m
         end
      end

      #
      # This class doesn't do much except +yield+ columns.
      #
      class ColumnEnum < MatrixEnum
         def each
            @m.hsize.times { |i|
               yield @m.column(i)
            }
            @m
         end
      end

      #
      # This class doesn't do much except +yield+ rows.
      #
      class RowEnum < MatrixEnum
         def each
            @m.vsize.times { |i|
               yield @m.row(i)
            }
            @m
         end
      end

      #
      # Returns an +Enumerable+ of the rows
      #
      def rows
         RowEnum.new(self)
      end

      #
      # Returns an +Enumerable+ of the columns
      #
      def columns
         ColumnEnum.new(self)
      end

      #
      # Returns an +Enumerable+ of the matrix elements
      #
      def elems
         ElemEnum.new(self)
      end

      #
      # Returns an +Enumerable+ of the diagonal elements
      #
      def diags
         DiagEnum.new(self)
      end

      #
      # Like <tt>Enumerable#each_with_index</tt>, but with an index pair
      #
      def each_with_index # :yields: e, i, j
         (0...hsize).each { |j|
            (0...vsize).each { |i|
               yield self[i,j], i, j
            }
         }
         self
      end

      #
      # Like <tt>Array#each_index</tt>, but with an index pair
      #
      def each_index
         (0...hsize).each { |j|
            (0...vsize).each { |i|
               yield i, j
            }
         }
         self
      end
      
      #
      # Like <tt>Enumerable#map</tt>, but the resultant is a another matrix
      #
      def map # :yields: e
         m = self.class.reserve(self.vsize, self.hsize)
         each_with_index { |e, i, j|
            m[i,j] = yield e
         }
         m
      end

      #
      # +map+ with an index pair
      #
      def map_with_index # :yields: e, i, j
         m = self.class.reserve(self.vsize, self.hsize)
         each_with_index { |e, i, j|
            m[i,j] = yield e, i, j
         }
         m
      end

      #
      # In-place +map+
      #
      def map! # :yields: e
         each_with_index { |e, i, j|
            self[i,j] = yield e
         }
         self
      end

      #
      # In-place +map_with_index+
      #
      def map_with_index! # :yields: e, i, j
         each_with_index { |e, i, j|
            self[i,j] = yield e, i, j
         }
         self
      end

      #
      # Visit below-diagonal elements, with index pair
      #
      def each_lower_with_index # :yields: e, i, j
         (0...hsize).each { |j|
            ((j+1)...vsize).each { |i|
               yield self[i,j], i, j
            }
         }
         self
      end

      #
      # Visit above-diagonal elements, with index pair
      #
      def each_upper_with_index # :yields: e, i, j
         (1...hsize).each { |j|
            (0...(j > vsize ? vsize : j)).each { |i|
               yield self[i,j], i, j
            }
         }
         self
      end

      private

      # this seems overkill.
      #
      # Like <tt>Enumerable#inject</tt>, but with an index pair
      #
      #def inject_with_index(initial) # :yields: memo, e, i, j
      #   res = initial
      #   each_with_index { |e, i, j|
      #      res = yield res, e, i, j
      #   }
      #   res
      #end

   end
end
   
