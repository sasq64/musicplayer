AC_INIT([tfmxplay], [1.1.7])
AC_CONFIG_SRCDIR([src/player.c])

AM_CONFIG_HEADER(config.h)
AM_INIT_AUTOMAKE

AC_C_BIGENDIAN
AC_LANG_C
AC_PROG_CC
AM_PROG_LIBTOOL

dnl ------------------------------------------------------------------------
dnl Find a file (or one of more files in a list of dirs)
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([AC_FIND_FILE],
[
$3=NO
for i in $2;
do
  for j in $1;
  do
    echo "configure: __oline__: $i/$j" >&AC_FD_CC
    if test -r "$i/$j"; then
      echo "taking that" >&AC_FD_CC
      $3=$i
      break 2
    fi
  done
done
])


dnl KDE_FIND_PATH(programm-name, variable-name, list of directories,
dnl     if-not-found, test-parameter)
AC_DEFUN(KDE_FIND_PATH,
[
   AC_MSG_CHECKING([for $1])
   if test -n "$$2"; then
        kde_cv_path="$$2";
   else
        kde_cache=`echo $1 | sed 'y%./+-%__p_%'`

        AC_CACHE_VAL(kde_cv_path_$kde_cache,
        [
        kde_cv_path="NONE"
        dirs="$3"
        kde_save_IFS=$IFS
        IFS=':'
        for dir in $PATH; do
          dirs="$dirs $dir"
        done
        IFS=$kde_save_IFS

        for dir in $dirs; do
          if test -x "$dir/$1"; then
            if test -n "$5"
            then
              evalstr="$dir/$1 $5 2>&1 "
              if eval $evalstr; then
                kde_cv_path="$dir/$1"
                break
              fi
            else
                kde_cv_path="$dir/$1"
                break
            fi
          fi
        done

        eval "kde_cv_path_$kde_cache=$kde_cv_path"

        ])

      eval "kde_cv_path=\"`echo '$kde_cv_path_'$kde_cache`\""

   fi

   if test -z "$kde_cv_path" || test "$kde_cv_path" = NONE; then
      AC_MSG_RESULT(not found)
      $4
   else
      AC_MSG_RESULT($kde_cv_path)
      $2=$kde_cv_path

   fi
])

KDE_FIND_PATH(sdl-config, LIBSDL_CONFIG, [${prefix}/bin ${exec_prefix}/bin /usr/local/bin /opt/local/bin], [
  AC_MSG_WARN([Could not find libsdl anywhere, check http://www.sdl.org])
])


if test -n "$LIBSDL_CONFIG"; then
     LIBSDL_LIBS="`$LIBSDL_CONFIG --libs`"
     LIBSDL_RPATH=
     for args in $LIBSDL_LIBS; do
          case $args in
            -L*)
               LIBSDL_RPATH="$LIBSDL_RPATH $args"
               ;;
          esac
     done
     LIBSDL_RPATH=`echo $LIBSDL_RPATH | sed -e "s/-L/-R/g"`
     LIBSDL_CFLAGS="`$LIBSDL_CONFIG --cflags`"

     AC_DEFINE_UNQUOTED(HAVE_LIBSDL, 1, [Defines if your system has the LIBSDL library])
fi


AC_SUBST(LIBSDL_LIBS)
AC_SUBST(LIBSDL_CFLAGS)
AC_SUBST(LIBSDL_RPATH)

AC_DEFUN([KDE_CHECK_LIB64],
[
    kdelibsuff=no
    AC_ARG_ENABLE(libsuffix,
        AC_HELP_STRING([--enable-libsuffix],
            [/lib directory suffix (64,32,none[=default])]),
            kdelibsuff=$enableval)
    # TODO: add an auto case that compiles a little C app to check
    # where the glibc is
    if test "$kdelibsuff" = "no"; then
       kdelibsuff=
    fi
    if test -z "$kdelibsuff"; then
        AC_MSG_RESULT([not using lib directory suffix])
        AC_DEFINE(KDELIBSUFF, [""], Suffix for lib directories)
    else
        if test "$libdir" = '${exec_prefix}/lib'; then
            libdir="$libdir${kdelibsuff}"
            AC_SUBST([libdir], ["$libdir"])  dnl ugly hack for lib64 platforms
        fi
        AC_DEFINE_UNQUOTED(KDELIBSUFF, ["\"${kdelibsuff}\""], Suffix for lib directories)
        AC_MSG_RESULT([using lib directory suffix $kdelibsuff])
    fi
])


dnl ------------------------------------------------------------------------
dnl Try to find the SSL headers and libraries.
dnl $(SSL_LDFLAGS) will be -Lsslliblocation (if needed)
dnl and $(SSL_INCLUDES) will be -Isslhdrlocation (if needed)
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([KDE_CHECK_SSL],
[
LIBSSL="-lssl -lcrypto"
AC_REQUIRE([KDE_CHECK_LIB64])

ac_ssl_includes=NO ac_ssl_libraries=NO
ssl_libraries=""
ssl_includes=""
AC_ARG_WITH(ssl-dir,
    AC_HELP_STRING([--with-ssl-dir=DIR],[where the root of OpenSSL is installed]),
    [  ac_ssl_includes="$withval"/include
       ac_ssl_libraries="$withval"/lib$kdelibsuff
    ])

want_ssl=yes
AC_ARG_WITH(ssl,
    AC_HELP_STRING([--without-ssl],[disable SSL checks]),
    [want_ssl=$withval])

if test $want_ssl = yes; then

AC_MSG_CHECKING(for OpenSSL)

AC_CACHE_VAL(ac_cv_have_ssl,
[#try to guess OpenSSL locations
  
  ssl_incdirs="/usr/include /usr/local/include /usr/ssl/include /usr/local/ssl/include $prefix/include $kde_extra_includes"
  ssl_incdirs="$ac_ssl_includes $ssl_incdirs"
  AC_FIND_FILE(openssl/ssl.h, $ssl_incdirs, ssl_incdir)
  ac_ssl_includes="$ssl_incdir"

  ssl_libdirs="/usr/lib$kdelibsuff /usr/local/lib$kdelibsuff /usr/ssl/lib$kdelibsuff /usr/local/ssl/lib$kdelibsuff $libdir $prefix/lib$kdelibsuff $exec_prefix/lib$kdelibsuff $kde_extra_libs"
  if test ! "$ac_ssl_libraries" = "NO"; then
    ssl_libdirs="$ac_ssl_libraries $ssl_libdirs"
  fi

  test=NONE
  ssl_libdir=NONE
  for dir in $ssl_libdirs; do
    try="ls -1 $dir/libssl*"
    if test=`eval $try 2> /dev/null`; then ssl_libdir=$dir; break; else echo "tried $dir" >&AC_FD_CC ; fi
  done

  ac_ssl_libraries="$ssl_libdir"

  ac_ldflags_safe="$LDFLAGS"
  ac_libs_safe="$LIBS"

  LDFLAGS="$LDFLAGS -L$ssl_libdir $all_libraries"
  LIBS="$LIBS $LIBSSL -lRSAglue -lrsaref"

  AC_TRY_LINK(,void RSAPrivateEncrypt(void);RSAPrivateEncrypt();,
  ac_ssl_rsaref="yes"
  ,
  ac_ssl_rsaref="no"
  )

  LDFLAGS="$ac_ldflags_safe"
  LIBS="$ac_libs_safe"

  if test "$ac_ssl_includes" = NO || test "$ac_ssl_libraries" = NO; then
    have_ssl=no
  else
    have_ssl=yes;
  fi

  ])

  eval "$ac_cv_have_ssl"

  AC_MSG_RESULT([libraries $ac_ssl_libraries, headers $ac_ssl_includes])

  AC_MSG_CHECKING([whether OpenSSL uses rsaref])
  AC_MSG_RESULT($ac_ssl_rsaref)

  AC_MSG_CHECKING([for easter eggs])
  AC_MSG_RESULT([none found])

else
  have_ssl=no
fi

if test "$have_ssl" = yes; then
  AC_MSG_CHECKING(for OpenSSL version)
  dnl Check for SSL version
  AC_CACHE_VAL(ac_cv_ssl_version,
  [

    cat >conftest.$ac_ext <<EOF
#include <openssl/opensslv.h>
#include <stdio.h>
    int main() {
 
#ifndef OPENSSL_VERSION_NUMBER
      printf("ssl_version=\\"error\\"\n");
#else
      if (OPENSSL_VERSION_NUMBER < 0x00906000)
        printf("ssl_version=\\"old\\"\n");
      else
        printf("ssl_version=\\"ok\\"\n");
#endif
     return (0);
    }
EOF

    ac_save_CPPFLAGS=$CPPFLAGS
    if test "$ac_ssl_includes" != "/usr/include"; then
        CPPFLAGS="$CPPFLAGS -I$ac_ssl_includes"
    fi

    if AC_TRY_EVAL(ac_link); then 

      if eval `./conftest 2>&5`; then
        if test $ssl_version = error; then
          AC_MSG_ERROR([$ssl_incdir/openssl/opensslv.h doesn't define OPENSSL_VERSION_NUMBER !])
        else
          if test $ssl_version = old; then
            AC_MSG_WARN([OpenSSL version too old. Upgrade to 0.9.6 at least, see http://www.openssl.org. SSL support disabled.])
            have_ssl=no
          fi
        fi
        ac_cv_ssl_version="ssl_version=$ssl_version"
      else
        AC_MSG_ERROR([Your system couldn't run a small SSL test program.
        Check config.log, and if you can't figure it out, send a mail to 
        David Faure <faure@kde.org>, attaching your config.log])
      fi

    else
      AC_MSG_ERROR([Your system couldn't link a small SSL test program.
      Check config.log, and if you can't figure it out, send a mail to 
      David Faure <faure@kde.org>, attaching your config.log])
    fi 
    CPPFLAGS=$ac_save_CPPFLAGS

  ])

  eval "$ac_cv_ssl_version"
  AC_MSG_RESULT($ssl_version)
fi

if test "$have_ssl" != yes; then
  LIBSSL="";
else
  AC_DEFINE(HAVE_SSL, 1, [If we are going to use OpenSSL])
  ac_cv_have_ssl="have_ssl=yes \
    ac_ssl_includes=$ac_ssl_includes ac_ssl_libraries=$ac_ssl_libraries ac_ssl_rsaref=$ac_ssl_rsaref"
  
  
  ssl_libraries="$ac_ssl_libraries"
  ssl_includes="$ac_ssl_includes"

  if test "$ac_ssl_rsaref" = yes; then
    LIBSSL="-lssl -lcrypto -lRSAglue -lrsaref" 
  fi

  if test $ssl_version = "old"; then
    AC_DEFINE(HAVE_OLD_SSL_API, 1, [Define if you have OpenSSL < 0.9.6])
  fi
fi

SSL_INCLUDES=

if test "$ssl_includes" = "/usr/include"; then
  if test -f /usr/kerberos/include/krb5.h; then
	SSL_INCLUDES="-I/usr/kerberos/include"
  fi
elif test  "$ssl_includes" != "/usr/local/include" && test -n "$ssl_includes"; then
  SSL_INCLUDES="-I$ssl_includes"
fi

if test "$ssl_libraries" = "/usr/lib" || test "$ssl_libraries" = "/usr/local/lib" || test -z "$ssl_libraries" || test "$ssl_libraries" = "NONE"; then
 SSL_LDFLAGS=""
else
 SSL_LDFLAGS="-L$ssl_libraries -R$ssl_libraries"
fi

AC_SUBST(SSL_INCLUDES)
AC_SUBST(SSL_LDFLAGS)
AC_SUBST(LIBSSL)
])

KDE_CHECK_SSL()

AC_OUTPUT(Makefile src/Makefile)
