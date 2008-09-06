/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#ifndef LINALG_H
#define LINALG_H

#include "ruby.h"

void raise_bad_array() ;
void raise_dim_error() ;
void raise_index_error() ;

extern VALUE rb_cLinalg ;
extern VALUE rb_cLinalgException ;
extern VALUE rb_eDimensionError ;

#endif
