dnl  Copyright (C) 2010 NorthScale, Inc
dnl This file is free software; NorthScale, Inc
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl **********************************************************************
dnl DETECT_SOCKLEN_T
dnl
dnl
dnl **********************************************************************
AC_DEFUN([AC_C_DETECT_SOCKLEN_T],
[
    AC_CACHE_CHECK([for print socklen_t],
        [ac_cv_c_socklen_t],
        [AC_TRY_COMPILE(
            [
#include <sys/types.h>
#include <sys/socket.h>
            ], [
  socklen_t len = 0;
            ],
            [ ac_cv_c_socklen_t=yes ],
            [ ac_cv_c_socklen_t=no ])
        ])
])

AC_DEFUN([PANDORA_HAVE_SOCKLEN_T],[
  AC_REQUIRE([AC_C_DETECT_SOCKLEN_T])
])

AC_DEFUN([PANDORA_REQUIRE_SOCKLEN_T],[
  AC_REQUIRE([AC_C_DETECT_SOCKLEN_T])
  AS_IF([test "x${ac_cv_c_socklen_t}" = "xno"],
    AC_MSG_ERROR([socklen_t is required for ${PACKAGE}]))
])
