#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg'

module Linalg
   module XData
      
      class NullClass
         def to_doublecomplex_ptr
            0
         end

         def to_complex_ptr
            0
         end
         
         def to_doublereal_ptr
            0
         end

         def to_real_ptr
            0
         end

         def to_integer_ptr
            0
         end
         
         def to_logical_ptr
            0
         end

         def to_char_ptr
            0
         end
         
         def to_L_fp
            0
         end
      end

      NULL = NullClass.new

      class DReal < DData
         def initialize(value = 0.0)
            super(1)
            self[0] = value
         end

         def value
            self[0]
         end
         
         def value=(a)
            self[0] = a
         end
      end

      class SReal < SData
         def initialize(value = 0.0)
            super(1)
            self[0] = value
         end

         def value
            self[0]
         end
         
         def value=(a)
            self[0] = a
         end
      end

      class XInteger < IData
         def initialize(value = 0)
            super(1)
            self[0] = value
         end

         def value
            self[0]
         end
         
         def value=(a)
            self[0] = a
         end
      end

      class Logical < LData
         def initialize(value = 0)
            super(1)
            self[0] = value
         end

         def value
            self[0]
         end
         
         def value=(a)
            self[0] = a
         end
      end

      class Char < CharData
         def initialize(value = "\0")
            super(1)
            self[0] = value
         end

         def value
            self[0]
         end
         
         def value=(a)
            self[0] = a
         end
      end
   end
end
