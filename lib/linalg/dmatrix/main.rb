#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

module Linalg
   
   class DMatrix
      include Iterators

      include XData # :nodoc:
      include Linalg::Exception # :nodoc:


      ##################################################
      #
      # singleton methods
      #
      ##################################################

      #
      # Create a matrix by joining together a list of column vectors
      #
      #   m == DMatrix.join_columns(m.columns.map { |x| x })
      #
      def self.join_columns(cols)
         col_vsize = cols[0].vsize
         res = DMatrix.reserve(col_vsize, cols.size)
         cols.each_with_index { |col, j|
            unless col.vsize == col_vsize
               raise DimensionError 
            end
            res.replace_column(j, col)
         }
         res
      end

      #
      # Create a matrix by joining together a list of row vectors
      #
      #   m == DMatrix.join_rows(m.rows.map { |x| x })
      #
      def self.join_rows(rows)
         row_hsize = rows[0].hsize
         res = DMatrix.reserve(rows.size, row_hsize)
         rows.each_with_index { |row, i|
            unless row.hsize == row_hsize
               raise DimensionError 
            end
            res.replace_row(i, row)
         }
         res
      end

      #
      # calls DMatrix.rows with a splat (*)
      #
      #   DMatrix[[1,2,3],[4,5,6]] 
      # is equivalent to
      #   DMatrix.rows [[1,2,3],[4,5,6]]
      #
      def self.[](*array)
         self.rows(array)
      end

      #
      # Create a matrix using the elements of +array+ as columns.
      #
      #   DMatrix.columns(array)
      # is equivalent to
      #   DMatrix.new(array[0].size, array.size) { |i,j| array[j][i] }
      #
      # +DimensionError+ is raised if +array+ is not rectangular.
      # 
      def self.columns(array)
         self.rows(array).transpose!
      end

      class << self
         attr_accessor :default_epsilon
      end
      
      #
      # rdoc can you see me?
      #
      self.default_epsilon = 1e-8

      ##################################################
      #
      # instance methods
      #
      ##################################################

      #
      # Returns the singleton class of the object.  Convenient for
      # setting the +default_epsilon+ on a per-object basis.
      #   b = DMatrix.rand(4, 4)
      #   a = b.map { |e| e + 0.0001 }
      #   a.class.default_epsilon  # => 1e-8
      #   a =~ b  # => false
      #   a.singleton_class.default_epsilon = 0.001
      #   a =~ b  # => true
      #
      def singleton_class
         class << self
            self
         end
      end

      #
      # True if element-wise identical values.
      #
      def ==(other)
         self.within(0.0, other)
      end

      #
      # Sum of diagonal elements.
      #
      def trace
         diags.inject(0.0) { |acc, e| acc + e }
      end

      #
      # Same as to_s but prepended with a newline for nice irb output
      #
      def inspect
         "\n" << self.to_s
      end

      #
      # Dump to an +eval+-able string
      #
      def inspect2
         res = "#{self.class}["
         vsize.times { |i|
            res << "["
            hsize.times { |j|
               res << self[i,j].to_s << ","
            }
            res.chop!
            res << "],"
         }
         res.chop!
         res << "]"
      end
      
      #
      # Dump to a readable string
      #
      def to_s(format = "% 10.6f")
         res = ""
         vsize.times { |i|
            hsize.times { |j|
               res << sprintf(format, self[i,j])
            }
            res << "\n"
         }
         res
      end

      #
      # Returns <tt>m[0,0]</tt> when +m+ is a 1x1 matrix, otherwise a
      # +TypeError+ is raised.
      #
      def to_f
         if vsize == 1 and hsize == 1
            self[0,0]
         else
            raise TypeError, "to_f called on nonscalar matrix"
         end
      end

      #
      # Implemented as
      #
      #   m.within(epsilon, other)
      #
      # where
      #   epsilon =
      #      self.singleton_class.default_epsilon ||
      #      self.class.default_epsilon
      #
      def =~(other)
         epsilon =
            self.singleton_class.default_epsilon ||
            self.class.default_epsilon

         self.within(epsilon, other)
      end

      #
      # Returns
      #   self.vsize == self.hsize
      #
      def square?
         self.vsize == self.hsize
      end

      #
      # Tests whether the matrix is symmetric within +epsilon+
      #
      def symmetric?(epsilon = (self.singleton_class.default_epsilon || self.class.default_epsilon))
         symmetric_private(epsilon)
      end

      #
      # Exchange the <tt>p</tt>-th row with the <tt>q</tt>-th row
      # 
      def exchange_rows(p, q)
         tmp = self.row(p)
         replace_row(p, self.row(q))
         replace_row(q, tmp)
      end
      
      #
      # Exchange the <tt>p</tt>-th column with the <tt>q</tt>-th column
      # 
      def exchange_columns(p, q)
         tmp = self.column(p)
         replace_column(p, self.column(q))
         replace_column(q, tmp)
      end
      
      private

      #
      # Create a column vector from the array
      #
      def self.column_vector(array)
         self.columns([array])
      end

      #
      # Create a row vector from the array
      #
      def self.row_vector(array)
         self.rows([array])
      end

   end
end

