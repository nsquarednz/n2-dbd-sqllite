Name: %(echo $PACKAGE)
Version: %(echo $VERSION)
# Release is passed through to our script. We concatenate on the dist flag.
# Dist is a magic variable that will populate our version. I.E. EL8.
Release: %(echo $RELEASE)%{?dist}
Summary: Perl DBD SQLLite library files for integration with SQLLite databases.
Group: Development/Languages/Perl
License: Perl
URL: https://github.com/nsquarednz/n2-cgi-session
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%global _binaries_in_noarch_packages_terminate_build 0

#BuildRequires:
# Define some dependencies that we require in order to use this module.
# The base Perl DBI module.
Requires: perl(DBI)

%description
N-Squared Software fork of 1.76.0 of the Perl DBD SQLLite module.

%post

#
# All build steps are done by build-packages.sh.
#

%prep

#
# All build steps are done by build-packages.sh.
#

%build

#
# All build steps are done by build-packages.sh.
#

%install

rm -rf %{buildroot}
cp -r %{_builddir} %{buildroot}
find %{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)

# Include the core files needed to execute the library code.
# This differs depending on the version of Redhat as newer versions include the version Number.
%if %{rhel} <= 8
/usr/local/lib64/perl5/auto/DBD/SQLite/SQLite.so
/usr/local/lib64/perl5/auto/DBD/SQLite/.packlist
/usr/local/lib64/perl5/auto/share/dist/DBD-SQLite/sqlite3ext.h
/usr/local/lib64/perl5/auto/share/dist/DBD-SQLite/sqlite3.h
/usr/local/lib64/perl5/auto/share/dist/DBD-SQLite/sqlite3.c
/usr/local/lib64/perl5/DBD/SQLite.pm
/usr/local/lib64/perl5/DBD/SQLite/VirtualTable.pm
/usr/local/lib64/perl5/DBD/SQLite/Fulltext_search.pod
/usr/local/lib64/perl5/DBD/SQLite/VirtualTable
/usr/local/lib64/perl5/DBD/SQLite/VirtualTable/FileContent.pm
/usr/local/lib64/perl5/DBD/SQLite/VirtualTable/PerlData.pm
/usr/local/lib64/perl5/DBD/SQLite/Constants.pm
/usr/local/lib64/perl5/DBD/SQLite/GetInfo.pm
/usr/local/lib64/perl5/DBD/SQLite/Cookbook.pod
%endif

%if %{rhel} >= 9
/usr/local/lib64/perl5/*/auto/DBD/SQLite/SQLite.so
/usr/local/lib64/perl5/*/auto/DBD/SQLite/.packlist
/usr/local/lib64/perl5/*/auto/share/dist/DBD-SQLite/sqlite3ext.h
/usr/local/lib64/perl5/*/auto/share/dist/DBD-SQLite/sqlite3.h
/usr/local/lib64/perl5/*/auto/share/dist/DBD-SQLite/sqlite3.c
/usr/local/lib64/perl5/*/DBD/SQLite.pm
/usr/local/lib64/perl5/*/DBD/SQLite/VirtualTable.pm
/usr/local/lib64/perl5/*/DBD/SQLite/Fulltext_search.pod
/usr/local/lib64/perl5/*/DBD/SQLite/VirtualTable
/usr/local/lib64/perl5/*/DBD/SQLite/VirtualTable/FileContent.pm
/usr/local/lib64/perl5/*/DBD/SQLite/VirtualTable/PerlData.pm
/usr/local/lib64/perl5/*/DBD/SQLite/Constants.pm
/usr/local/lib64/perl5/*/DBD/SQLite/GetInfo.pm
/usr/local/lib64/perl5/*/DBD/SQLite/Cookbook.pod
%endif

# Bundle the DBD SQLLite man pages.
/usr/local/share/man/man3/DBD::SQLite.3pm
/usr/local/share/man/man3/DBD::SQLite::Cookbook.3pm
/usr/local/share/man/man3/DBD::SQLite::VirtualTable::PerlData.3pm
/usr/local/share/man/man3/DBD::SQLite::VirtualTable::FileContent.3pm
/usr/local/share/man/man3/DBD::SQLite::Fulltext_search.3pm
/usr/local/share/man/man3/DBD::SQLite::Constants.3pm
/usr/local/share/man/man3/DBD::SQLite::VirtualTable.3pm

%changelog
