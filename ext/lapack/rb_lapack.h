/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#include "ruby.h"

#include <g2c.h>

#include "include/BLAS.h"
#include "include/LAPACK.h"

extern VALUE to_char_ptr ;

extern VALUE to_real_ptr ;
extern VALUE to_doublereal_ptr ;

extern VALUE to_complex_ptr ;
extern VALUE to_doublecomplex_ptr ;

extern VALUE to_integer_ptr ;
extern VALUE to_logical_ptr ;

extern VALUE to_L_fp ;

extern VALUE rb_cLinalg ;
extern VALUE rb_cLapack ;

void define_lapack_s(void) ;
void define_lapack_d(void) ;
void define_lapack_c(void) ;
void define_lapack_z(void) ;
void define_lapack_x(void) ;
    
