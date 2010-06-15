AC_PREREQ(2.59)
m4_include([m4/version.m4])
AC_INIT(memcached, VERSION_NUMBER, memcached@googlegroups.com)
AC_CONFIG_SRCDIR([memcached.c])
AC_CONFIG_AUX_DIR(config)
AM_CONFIG_HEADER([config.h])
AC_CONFIG_MACRO_DIR([m4])
AC_DISABLE_STATIC

if test "x${enable_dependency_tracking}" = "x"
then
  enable_dependency_tracking=yes
fi

AH_TOP([
#ifndef CONFIG_H
#define CONFIG_H
])

PANDORA_CANONICAL_TARGET(less-warnings, warnings-always-on, force-gcc42, c-only)
PANDORA_REQUIRE_PTHREAD
PANDORA_REQUIRE_LIBEVENT
PANDORA_REQUIRE_C99_PRINTF_MACROS
PANDORA_REQUIRE_SOCKLEN_T
PANDORA_HAVE_HTONLL

AC_SEARCH_LIBS(clock_gettime, rt)
AC_SEARCH_LIBS(socket, socket)
AC_SEARCH_LIBS(gethostbyname, nsl)
AC_SEARCH_LIBS(umem_cache_create, umem)
AC_SEARCH_LIBS(gethugepagesizes, hugetlbfs)
AC_SEARCH_LIBS(dlopen, dl)
AC_SEARCH_LIBS(log, m)
AC_CHECK_HEADERS(link.h dlfcn.h inttypes.h umem.h priv.h)
AC_HEADER_STDBOOL
AC_CHECK_FUNCS(mlockall getpagesizes memcntl sigignore setppriv)

AC_ARG_ENABLE(sasl,
  [AS_HELP_STRING([--enable-sasl],[Enable SASL authentication])])
AC_ARG_ENABLE(isasl,
  [AS_HELP_STRING([--enable-isasl],[Enable internal SASL implementation])])
AC_ARG_ENABLE(sasl_pwdb,
  [AS_HELP_STRING([--enable-sasl-pwdb],[Enable plaintext password db])])

AS_IF([test "x$enable_sasl_pwdb" = "xyes"],
      [enable_sasl=yes ])

if test "x$enable_isasl" = "xyes"; then
  AC_DEFINE([ENABLE_ISASL],1,[Set to nonzero if you want to include ISASL])
  ac_cv_saslpasswd2="isasl"
  if test "x$enable_sasl" = "xyes"; then
      AC_MSG_ERROR([You can't specify isasl and sasl at the same time])
  fi
elif test "x$enable_sasl" = "xyes"; then
  AC_PATH_PROG(ac_cv_saslpasswd2, saslpasswd2, ,/usr/sbin:/usr/bin:/usr/local/bin:/usr/opt/bin/:/opt/bin)
  AC_DEFINE([ENABLE_SASL],1,[Set to nonzero if you want to include SASL])
  AC_SEARCH_LIBS([sasl_server_init], [sasl2 sasl], [],
    [
      AC_MSG_ERROR([Failed to locate the library containing sasl_server_init])
    ])

  AS_IF([test "x$enable_sasl_pwdb" = "xyes"],
        [AC_DEFINE([ENABLE_SASL_PWDB], 1,
                   [Set to nonzero if you want to enable a SASL pwdb])])
  # test user supplied saslpasswd2 path - if supplied, or try to locate
  AC_ARG_WITH(saslpasswd2,
       [  --with-saslpasswd2=PATH  Specify location of saslpasswd2 binary],
       [
                if test "x$withval" != "xno" ; then
                  if test ! -x $withval ; then
                    AC_MSG_ERROR([The filename and/or path supplied to saslpasswd2 is wrong!])
                  else
                    ac_cv_saslpasswd2=$withval
                  fi
                fi
       ]
  )

  AC_CACHE_CHECK([for saslpasswd2 binary location], ac_cv_saslpasswd2, [
    if test -z "$ac_cv_saslpasswd2"; then
      AC_MSG_ERROR([saslpasswd2 is required if sasl is enabled.

      If it's already installed, specify its path using --with-saslpasswd=/full/path/saslpasswd2
      ])
    fi
  ])
fi
# even though the test won't run if no sasl, still need to generate
SASLPASSWD2=$ac_cv_saslpasswd2
AC_SUBST(SASLPASSWD2)
AC_CONFIG_FILES(t/binary-sasl.t)


AC_ARG_ENABLE(default-engine,
  [AS_HELP_STRING([--enable-default-engine], [Build-in default engine])])
AM_CONDITIONAL([INCLUDE_DEFAULT_ENGINE],[test "$enable_default_engine" = "yes"])

AM_CONDITIONAL([ENABLE_SASL],[test "$enable_sasl" = "yes"])
AM_CONDITIONAL([ENABLE_ISASL],[test "$enable_isasl" = "yes"])

AC_SUBST(ENABLE_SASL)
AC_SUBST(ENABLE_ISASL)
AC_SUBST(PROFILER_LDFLAGS)

AC_ARG_ENABLE(coverage,
  [AS_HELP_STRING([--enable-coverage],[Disable code coverage])])

if test "x$enable_coverage" = "xyes"; then
   if test "$ICC" = "yes"
   then
      AC_MSG_WARN([icc doesn't support code coverage checking])
   elif test "$GCC" = "yes"
   then
      AC_PATH_PROG([PROFILER], [gcov], "no", [$PATH])
      if test "x$PROFILER" != "xno"; then
         # Issue 97: The existense of gcov doesn't mean we have -lgcov
         AC_CHECK_LIB(gcov, main,
                    [
                      PROFILER_FLAGS="-fprofile-arcs -ftest-coverage"
                      PROFILER_LDFLAGS="-lgcov"
                    ], [
                      PROFILER_FLAGS=
                      PROFILER_LDFLAGS=
                    ])
      fi
   elif test "$SUNCC" = "yes"
   then
      AC_PATH_PROG([PROFILER], [tcov], "no", [$PATH])
      if test "x$PROFILER" != "xno"; then
         PROFILER_FLAGS=-xprofile=tcov
      fi
   fi
fi
AC_SUBST(PROFILER_FLAGS)




dnl Check for the requirements for running memcached with less privileges
dnl than the default privilege set. On Solaris we need setppriv and priv.h
dnl If you want to add support for other platforms you should check for
dnl your requirements, define HAVE_DROP_PRIVILEGES, and make sure you add
dnl the source file containing the implementation into memcached_SOURCE
dnl in Makefile.am
AS_IF([test "x${ac_cv_header_priv_h}" = "xyes" -a "x${ac_cv_func_setppriv}" = "xyes"], [
      AC_DEFINE([HAVE_DROP_PRIVILEGES], 1,
         [Define this if you have an implementation of drop_privileges()])
      build_solaris_privs=yes
   ])
AM_CONDITIONAL([BUILD_SOLARIS_PRIVS], test "$build_solaris_privs" = "yes")

AM_CONDITIONAL([BUILD_CACHE], test "x$ac_cv_header_umem_h" = "xno")

dnl ----------------------------------------------------------------------------
dnl Don't generate text files from the XML documents by default.
dnl Most developers just run ./configure and will run a lot of make / make clean
dnl and we don't want them to spend their time waiting for doc generation ;-)
dnl If you really want the documents you should be capable of adding
dnl --enable-docs yourself...
AC_ARG_ENABLE([docs],
  [AS_HELP_STRING([--enable-docs],
     [Generate documentation @<:@default=off@:>@])],
  [ac_enable_docs="$enableval"],
  [ac_enable_docs="no"])

AS_IF([test "x$ac_enable_docs" = "xyes"],
      [
         AC_PATH_PROG([XML2RFC], [xml2rfc], "no")
         AS_IF([test "x$XML2RFC" = "xno"],
               [AC_MSG_ERROR([Can't build documentation without xml2rfc.])])
         AC_PATH_PROG([XSLTPROC], [xsltproc], "no")
         AS_IF([test "x$XSLTPROC" = "xno"],
               [AC_MSG_ERROR([Can't build documentation without xsltproc.])])
      ])

AM_CONDITIONAL([BUILD_SPECIFICATIONS], [test "x$ac_enable_docs" = "xyes"])

dnl ----------------------------------------------------------------------------

AC_DEFUN([AC_C_ALIGNMENT],
[AC_CACHE_CHECK(for alignment, ac_cv_c_alignment,
[
  AC_RUN_IFELSE(
    [AC_LANG_PROGRAM([
#include <stdlib.h>
#include <inttypes.h>
    ], [
       char *buf = malloc(32);

       uint64_t *ptr = (uint64_t*)(buf+2);
       // catch sigbus, etc.
       *ptr = 0x1;

       // catch unaligned word access (ARM cpus)
       *buf =  1; *(buf +1) = 2; *(buf + 2) = 2; *(buf + 3) = 3; *(buf + 4) = 4;
       int* i = (int*)(buf+1);
       return (84148994 == i) ? 0 : 1;
    ])
  ],[
    ac_cv_c_alignment=none
  ],[
    ac_cv_c_alignment=need
  ])
])
if test $ac_cv_c_alignment = need; then
  AC_DEFINE(NEED_ALIGN, 1, [Machine need alignment])
fi
])

AC_C_ALIGNMENT

dnl Let the compiler be a bit more picky. Please note that you cannot
dnl specify these flags to the compiler before AC_CHECK_FUNCS, because
dnl the test program will generate a compilation warning and hence fail
dnl to detect the function ;-)
if test "$ICC" = "yes"
then
   dnl ICC trying to be gcc.
   CFLAGS="$CFLAGS -diag-disable 187 -Wall -Werror"
   AC_DEFINE([_GNU_SOURCE],[1],[find sigignore on Linux])
elif test "$GCC" = "yes"
then
   CFLAGS="$CFLAGS -fvisibility=hidden"
   AC_DEFINE([_GNU_SOURCE],[1],[find sigignore on Linux])
elif test "$SUNCC" = "yes"
then
  CFLAGS="$CFLAGS -xldscope=hidden"
fi

AH_BOTTOM([
#if HAVE_STDBOOL_H
#include <stdbool.h>
#else
#define bool char
#define false 0
#define true 1
#endif

#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif

#ifdef WORDS_BIGENDIAN
#define ENDIAN_BIG 1
#else
#define ENDIAN_LITTLE 1
#endif

#endif
])

dnl ----------------------------------------------------------------------------
dnl Check for stuff needed to run Doxygen
AC_PATH_PROG([DOT], [dot], "no")
AS_IF(test "x$DOT" = "xno", [HAVE_DOT=NO], [HAVE_DOT=YES])
AC_PATH_PROG([DOXYGEN], [doxygen], "doxygen")
AC_PATH_PROG([PERL], [perl], "perl")
AC_SUBST(HAVE_DOT)
PROJECT_NUMBER=VERSION_NUMBER
AC_SUBST(PROJECT_NUMBER)

dnl ----------------------------------------------------------------------------
CPPFLAGS="-I\${top_srcdir}/include ${CPPFLAGS}"
AC_CONFIG_FILES(Makefile  config/Doxyfile config/Doxyfile-api)
dnl doc/Makefile config/Doxyfile config/Doxyfile-api)
AC_OUTPUT
echo "---"
echo "Configuration summary for $PACKAGE_NAME version $VERSION"
echo ""
echo "   * Installation prefix:       $prefix"
echo "   * System type:               $host_vendor-$host_os"
echo "   * Host CPU:                  $host_cpu"
echo "   * C Compiler:                $CC_VERSION"
echo "   * C++ Compiler:              $CXX_VERSION"
echo "   * Assertions enabled:        $ac_cv_assert"
echo "   * Debug enabled:             $with_debug"
echo "   * Warnings as failure:       $ac_cv_warnings_as_errors"
echo ""
echo "---"
