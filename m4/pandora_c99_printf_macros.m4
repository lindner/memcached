dnl  Copyright (C) 2010 NorthScale, Inc
dnl This file is free software; NorthScale, Inc
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl **********************************************************************
dnl DETECT_C99_PRINTF_MACROS
dnl
dnl check if we can use a uint64_t printf macro
dnl **********************************************************************
AC_DEFUN([AC_C_DETECT_C99_PRINTF_MACROS],
[
    AC_CACHE_CHECK([for print macros for integers (C99 section 7.8.1)],
        [ac_cv_c_c99_printf_macros],
        [AC_TRY_COMPILE(
            [
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif
#include <stdio.h>
            ], [
  uint64_t val = 0;
  (void)fprintf(stderr, "%" PRIu64 "\n", val);
            ],
            [ ac_cv_c_c99_printf_macros=yes ],
            [ ac_cv_c_c99_printf_macros=no ])
        ])
])

AC_DEFUN([PANDORA_HAVE_C99_PRINTF_MACROS],[
  AC_REQUIRE([AC_C_DETECT_C99_PRINTF_MACROS])
])

AC_DEFUN([PANDORA_REQUIRE_C99_PRINTF_MACROS],[
  AC_REQUIRE([AC_C_DETECT_C99_PRINTF_MACROS])
  AS_IF([test "x${ac_cv_c_c99_printf_macros}" = "xno"],
    AC_MSG_ERROR([Failed to use print macros (PRIu) as defined in C99 section 7.8.1. These macros is required for ${PACKAGE}]))
])
