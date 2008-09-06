#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      #
      # Returns a matrix whose columns form an orthogonal basis for the
      # nullspace.  (This is simply taken from <tt>vt.t</tt> in DMatrix#svd.)
      # Returns +nil+ if the matrix is of full rank.
      #
      # For matrix +m+, a singular value less than or equal
      # to <tt>m.norm*epsilon</tt> is considered a rank
      # deficiency.
      #
      def nullspace(epsilon = (self.singleton_class.default_epsilon ||self.class.default_epsilon))
         u, s, vt = self.svd
         v = vt.transpose!
         null_indexes = sv_null_indexes(s.diags, s[0,0]*epsilon)

         if null_indexes.empty?
            nil
         else
            ns = DMatrix.reserve(v.vsize, null_indexes.size)
            null_indexes.each_with_index { |e, j|
               ns.replace_column(j, v.column(e))
            }
            ns
         end
      end

      #
      # Returns a matrix whose columns form an orthonormal basis
      # for the span of the matrix.
      #
      # This is just the complement of the nullspace.
      # See DMatrix#nullspace.
      #
      def rankspace(epsilon = (self.singleton_class.default_epsilon ||self.class.default_epsilon))
         u, s, vt = self.svd
         v = vt.transpose!
         null_indexes = sv_null_indexes(s.diags, s[0,0]*epsilon)

         if null_indexes.empty?
            v
         else
            orth_indexes = (0...v.hsize).to_a - null_indexes
            orth = DMatrix.reserve(v.vsize, orth_indexes.size)
            orth_indexes.each_with_index { |e, j|
               orth.replace_column(j, v.column(e))
            }
            orth
         end
      end

      #
      # Returns the column rank of the matrix.
      #   hsize == rank + nullity
      #
      # see DMatrix#nullspace
      #
      def rank(epsilon = (self.singleton_class.default_epsilon ||self.class.default_epsilon))
         sv = self.sv
         indexes = sv_null_indexes(sv, sv[0]*epsilon)
         indexes ? (hsize - indexes.size) : 0
      end

      #
      # Returns the nullity of the matrix (the dimension of the nullspace).
      #   hsize == rank + nullity
      #
      # see DMatrix#nullspace
      #
      def nullity(epsilon = self.class.default_epsilon)
         sv = self.sv
         indexes = sv_null_indexes(sv, sv[0]*epsilon)
         indexes ? indexes.size : 0
      end
      
      #
      # True if the rank less than number of columns.
      #
      # see DMatrix#nullspace
      #
      def singular?(epsilon = (self.singleton_class.default_epsilon ||self.class.default_epsilon))
         not regular?(epsilon)
      end

      #
      # True if the rank is equal to the number of columns.
      #
      # see DMatrix#nullspace
      #
      def regular?(epsilon = (self.singleton_class.default_epsilon ||self.class.default_epsilon))
         square? and rank(epsilon) == hsize
      end

      private

      def sv_null_indexes(sv, epsilon)
         nulls = []
         sv.each_with_index { |e, i|
            nulls << i if e.abs <= epsilon 
         }
         nulls += (self.vsize...self.hsize).to_a
         nulls
      end
   end
end


