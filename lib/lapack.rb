#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'rbconfig'

require "lapack.#{Config::CONFIG['DLEXT']}"

#
# Simple, strongly-typed bindings to LAPACK.
#
# Every LAPACK subroutine is accessible from the +Lapack+ module
#
#   Lapack.methods.size  # => 1498
#
# and each subroutine corresponds to a +Lapack+ module method
# of the same name
#
#   Lapack.methods.include? "dgemm"  # => true
#
# The +Lapack+ module knows the type signature of each LAPACK
# subroutine.  With this signature it calls the appropriate method:
#
#    to_real_ptr
#    to_doublereal_ptr
#    to_complex_ptr
#    to_doublecomplex_ptr
#    to_integer_ptr
#    to_logical_ptr
#    to_L_fp_ptr
#    to_char_ptr
#
# on each parameter passed.  For example,
# 
#   Lapack.dgemm(transa,  # calls transa.to_integer_ptr
#                transb,  # calls transb.to_integer_ptr
#                m,       # calls m.to_integer_ptr
#                n,       # calls n.to_integer_ptr
#                k,       # calls k.to_integer_ptr
#                alpha,   # calls alpha.to_doublereal_ptr
#                a,       # calls a.to_doublereal_ptr
#                lda,     # calls lda.to_integer_ptr
#                b,       # calls b.to_doublereal_ptr
#                ldb,     # calls b.to_integer_ptr
#                beta,    # calls beta.to_doublereal_ptr
#                c,       # calls c.to_doublereal_ptr
#                ldc)     # calls ldc.to_integer_ptr
# 
# The type names are taken directly from g2c.h.
#
#    real
#    doublereal
#    complex
#    doublecomplex
#    integer
#    logical
#    L_fp
#    char
#
# Each <tt>to_FORTRANTYPE_ptr</tt> method returns the actual pointer
# value of some data.
#
# Where do you find classes which so promiscuously expose pointer
# values?  Well, you make them from your own extension classes, or you
# may use some generic classes which are provided.  See Linalg::XData
# for some very simple data classes.
#
# It should be emphasized that there is no preferred class or data
# structure for interacting with the +Lapack+ module.  All +Lapack+
# requires is that the appropriate to_FORTRANTYPE_ptr be implemented
# on each parameter passed.  From this perspective it is questionable
# whether +Lapack+ should even be bundled with the +linalg+ package.
#
# +DMatrix+, for example, is just a class which implements
# the <tt>to_doublereal_ptr</tt> method, and the entirety of its
# communication from ruby to +Lapack+ goes through that method.
#
# For C extension writers: While C's +double+, for example, is almost
# surely the same as +doublereal+, to ensure portability it is
# generally good practice to use the aforementioned types found in the
# g2c.h header on your system.
#
#
module Lapack
end
