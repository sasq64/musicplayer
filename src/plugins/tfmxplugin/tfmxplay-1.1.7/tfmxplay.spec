#
# spec file for package sakuraplayer
# 

Vendor:       suse
Distribution: SuSE Linux 8.2 (i386)
Name:         tfmxplay
Packager:     neko@netcologne.de

Copyright:    GPL
Group:        Productivity/Multimedia/Sound/Players
Summary:      Player for TFMX music files
BuildRoot:    /var/tmp/%{name}-buildroot
Version:      1.1.7
Release:      1
Source0:      %{name}-%{version}.tar.gz
Provides:     tfmx-play
Provides:     tfmxplay
Obsoletes:    tfmx-play
Conflicts:    tfmxcess
Conflicts:    sakuraplayer
Requires:     openssl
Requires:     SDL

%description


Authors:
--------
    David Banz <neko@netcologne.de>,
    Jonathan H. Pickard <marxmarv@antigates.com>
    and others

%prep
%setup

%build
[ ! -x ./configure ] && make -f Makefile.cvs
CXXFLAGS="$CXXFLAGS -DNDEBUG  $OPT_LEVEL " ./configure --prefix=/usr

make

%install
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}
make DESTDIR=$RPM_BUILD_ROOT install-strip

install -d $RPM_BUILD_ROOT/usr/share/doc/packages/tfmxplay
install -m 644 ./README $RPM_BUILD_ROOT/usr/share/doc/packages/tfmxplay
install -m 644 ./COPYING $RPM_BUILD_ROOT/usr/share/doc/packages/tfmxplay
install -m 644 ./ChangeLog $RPM_BUILD_ROOT/usr/share/doc/packages/tfmxplay
install -m 644 ./INSTALL $RPM_BUILD_ROOT/usr/share/doc/packages/tfmxplay

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}
rm -f ${RPM_BUILD_DIR}/kde%{name}.list

%files
%defattr(-,root,root)
/usr/bin/tfmx-play
/usr/share/doc/packages/tfmxplay/README
/usr/share/doc/packages/tfmxplay/COPYING
/usr/share/doc/packages/tfmxplay/ChangeLog
/usr/share/doc/packages/tfmxplay/INSTALL

%changelog
* Fri Apr 02 2004 David Banz <neko@netcologne.de>
- ported to autoconf/automake
* Sun Nov 09 2003 David Banz <neko@netcologne.de>
- fixed obsolete e-mail addressed
* Tue Jul 15 2003 David Banz <david.banz@imk.fraunhofer.de>
- repackaged SDL-based version (/usr/bin/ is used instead of
/usr/local/bin/)
