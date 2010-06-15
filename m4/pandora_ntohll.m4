dnl  Copyright (C) 2010 NorthScale, Inc
dnl This file is free software; NorthScale, Inc
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl **********************************************************************
dnl DETECT_HTONLL
dnl **********************************************************************
AC_DEFUN([AC_C_DETECT_HTONLL],
[
    AC_CACHE_CHECK([for ntohll],
        [ac_cv_c_ntohll],
        [AC_RUN_IFELSE([
            AC_LANG_PROGRAM([
#include <sys/types.h>
#include <netinet/in.h>
#ifdef HAVE_INTTYPES_H
#include <inttypes.h> */
#endif
            ], [
return htonll(0);
            ])
            ],
            [ ac_cv_c_ntohll=yes ],
            [ ac_cv_c_ntohll=no ])
        ])
    AS_IF([ test "x${ac_cv_c_ntohll}" = "xyes" ],
          [
            AC_DEFINE([HAVE_HTONLL], 1, [Have ntohll])
          ])
])

AC_DEFUN([PANDORA_HAVE_HTONLL],[
  AC_REQUIRE([AC_C_DETECT_HTONLL])
])

AC_DEFUN([PANDORA_REQUIRE_HTONLL],[
  AC_REQUIRE([AC_C_DETECT_HTONLL])
  AS_IF([test "x${ac_cv_c_htonll}" = "xno"],
    AC_MSG_ERROR([htonll is required for ${PACKAGE}]))
])

AC_DEFUN([PANDORA_ENSURE_HTONLL],[
  AC_REQUIRE([AC_C_DETECT_HTONLL])
  AH_BOTTOM([
#ifndef HAVE_HTONLL
static uint64_t mc_swap64(uint64_t in) {
#ifdef ENDIAN_LITTLE
    /* Little endian, flip the bytes around until someone makes a faster/better
    * way to do this. */
    int64_t rv = 0;
    int i = 0;
     for(i = 0; i<8; i++) {
        rv = (rv << 8) | (in & 0xff);
        in >>= 8;
     }
    return rv;
#else
    /* big-endian machines don't need byte swapping */
    return in;
#endif
}

static uint64_t ntohll(uint64_t val) {
   return mc_swap64(val);
}

static uint64_t htonll(uint64_t val) {
   return mc_swap64(val);
}
#endif
  ])
])