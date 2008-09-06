/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#ifndef LINALG_XDATA_H
#define LINALG_XDATA_H

#include "ruby.h"

#include <g2c.h>

#include "linalg.h"
#include "dcomplex.h"
#include "scomplex.h"

void Init_sdata(void) ;
void Init_ddata(void) ;

void Init_cdata(void) ;
void Init_zdata(void) ;

void Init_ldata(void) ;
void Init_idata(void) ;

void Init_chardata(void) ;

extern VALUE rb_cXData ;

#endif

