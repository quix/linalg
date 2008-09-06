/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#include "rb_lapack.h"

VALUE to_char_ptr ;

VALUE to_real_ptr ;
VALUE to_doublereal_ptr ;

VALUE to_complex_ptr ;
VALUE to_doublecomplex_ptr ;

VALUE to_integer_ptr ;
VALUE to_logical_ptr ;

VALUE to_L_fp ;

VALUE rb_cLinalg ;
VALUE rb_cLapack ;

void Init_lapack()
{
    to_char_ptr = rb_intern("to_char_ptr") ;

    to_real_ptr = rb_intern("to_real_ptr") ;
    to_doublereal_ptr = rb_intern("to_doublereal_ptr") ;

    to_complex_ptr = rb_intern("to_complex_ptr") ;
    to_doublecomplex_ptr = rb_intern("to_doublecomplex_ptr") ;

    to_integer_ptr = rb_intern("to_integer_ptr") ;
    to_logical_ptr = rb_intern("to_logical_ptr") ;

    to_L_fp = rb_intern("to_L_fp") ;

    rb_cLinalg = rb_define_module("Linalg") ;
    rb_cLapack = rb_define_module_under(rb_cLinalg, "Lapack") ;

    define_lapack_s() ;
    define_lapack_d() ;
    define_lapack_c() ;
    define_lapack_z() ;
    define_lapack_x() ;
}
