# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
WANT_LIBTOOL="none"

inherit autotools flag-o-matic pax-utils ${PN}-utils-r1 toolchain-funcs multiprocessing

MY_P="Python-${PV}"
PATCHSET="${PN}-gentoo-patches-${PV}-r4"

DESCRIPTION="An interpreted, interactive, object-oriented programming language"
HOMEPAGE="https://www.${PN}.org/"
SRC_URI="${HOMEPAGE}ftp/${PN}/${PV}/${MY_P}.tar.xz
	https://dev.gentoo.org/~mgorny/dist/${PN}/${PATCHSET}.tar.xz"
S="${WORKDIR}/${MY_P}"

LICENSE="PSF-2"
SLOT="2.7"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 s390 sparc x86"
IUSE="-berkdb bluetooth build elibc_uclibc examples gdbm hardened ipv6 l10n_et-EE libressl +lto +ncurses +pgo +readline sqlite +ssl test +threads tk +wide-unicode wininst +xml"

# Do not add a dependency on dev-lang/${PN} to this ebuild.
# If you need to apply a patch which requires ${PN} for bootstrapping, please
# run the bootstrap code on your dev box and include the results in the
# patchset. See bug 447752.

RDEPEND="app-arch/bzip2:=
	virtual/libffi:=
	>=sys-libs/zlib-1.1.3:=
	virtual/libcrypt:=
	virtual/libintl
	berkdb? ( || (
		sys-libs/db:5.3
		sys-libs/db:5.1
		sys-libs/db:4.8
		sys-libs/db:4.7
		sys-libs/db:4.6
		sys-libs/db:4.5
		sys-libs/db:4.4
		sys-libs/db:4.3
		sys-libs/db:4.2
	) )
	gdbm? ( sys-libs/gdbm:=[berkdb] )
	ncurses? ( >=sys-libs/ncurses-5.2:= )
	readline? ( >=sys-libs/readline-4.1:= )
	sqlite? ( >=dev-db/sqlite-3.3.8:3= )
	ssl? (
		!libressl? ( dev-libs/openssl:= )
		libressl? ( dev-libs/libressl:= )
	)
	tk? (
		>=dev-lang/tcl-8.0:=
		>=dev-lang/tk-8.0:=
		dev-tcltk/blt:=
		dev-tcltk/tix
	)
	xml? ( >=dev-libs/expat-2.1:= )
	!!<sys-apps/portage-2.1.9"
# bluetooth requires headers from bluez
DEPEND="${RDEPEND}
	bluetooth? ( net-wireless/bluez )
	virtual/pkgconfig
	!<sys-devel/gcc-4.3[libffi(-)]"
RDEPEND+="
	!build? ( virtual/mime-types )
	!<=dev-lang/${PN}-exec-2.4.6-r1"
PDEPEND=">=app-eselect/eselect-${PN}-20140125-r1"

pkg_setup() {
	if use berkdb; then
		ewarn "'bsddb' module is out-of-date and no longer maintained inside"
		ewarn "dev-lang/${PN}. 'bsddb' and 'dbhash' modules have been additionally"
		ewarn "removed in Python 3. A maintained alternative of 'bsddb3' module"
		ewarn "is provided by dev-${PN}/bsddb3."
	else
		if has_version "=${CATEGORY}/${PN}-${PV%%.*}*[berkdb]"; then
			ewarn "You are migrating from =${CATEGORY}/${PN}-${PV%%.*}*[berkdb]"
			ewarn "to =${CATEGORY}/${PN}-${PV%%.*}*[-berkdb]."
			ewarn "You might need to migrate your databases."
		fi
	fi
}

src_prepare() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat || die
	rm -fr Modules/_ctypes/libffi* || die
	rm -fr Modules/zlib || die

	#known version relevance:
	#0012: 2.7.5+
	#0013: 2.7.9+
	#0014/0015: 2.7.10+
	local PATCHES=(
		"${WORKDIR}/${PATCHSET}/0001-bpo-39017-Avoid-infinite-loop-in-the-tarfile-module-.patch"
		"${WORKDIR}/${PATCHSET}/0002-bpo-39503-CVE-2020-8492-Fix-AbstractBasicAuthHandler.patch"
		"${WORKDIR}/${PATCHSET}/0005-bpo-41944-No-longer-call-eval-on-content-received-vi.patch"
		"${WORKDIR}/${PATCHSET}/0007-Install-lib${PN}X.Y.a-in-usr-lib-instead-of-usr-lib.patch"
		"${WORKDIR}/${PATCHSET}/0008-Disable-modules-and-SSL.patch"
		"${WORKDIR}/${PATCHSET}/0009-Gentoo-libdir.patch"
		"${WORKDIR}/${PATCHSET}/0010-Non-zero-exit-status-on-failure.patch"
		"${WORKDIR}/${PATCHSET}/0012-Regenerate-platform-specific-modules.patch"
		"${WORKDIR}/${PATCHSET}/0013-distutils-C.patch"
		"${WORKDIR}/${PATCHSET}/0014-Turkish-locale.patch"
		"${WORKDIR}/${PATCHSET}/0016-use_pyxml.patch"
		"${WORKDIR}/${PATCHSET}/0017-Disable-nis.patch"
		"${WORKDIR}/${PATCHSET}/0018-Make-module-byte-compilation-non-fatal.patch"
		"${WORKDIR}/${PATCHSET}/0019-Use-ncurses-to-find-pkg-config.patch"
		"${WORKDIR}/${PATCHSET}/0020-Use-specific-Werror-for-cross-compile-tests.patch"
		"${WORKDIR}/${PATCHSET}/0021-Force-using-system-libffi.patch"
	)
	use pgo && PATCHES+=( "${FILESDIR}/${PN}-2.7.15-PGO-r1.patch" )
	use sqlite && PATCHES+=( "${WORKDIR}/${PATCHSET}/0011-sqlite-loadable-extensions.patch" )
	use test && PATCHES+=( "${WORKDIR}/${PATCHSET}/0022-test.support.unlink-ignore-EACCES.patch" )

	default

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Lib/sysconfig.py \
		Lib/test/test_site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	eautoreconf
}

src_configure() {
	# dbm module can be linked against berkdb or gdbm.
	# Defaults to gdbm when both are enabled, #204343.
	local disable
	use berkdb    || use gdbm || disable+=" dbm"
	use berkdb    || disable+=" _bsddb"
	# disable automagic bluetooth headers detection
	use bluetooth || export ac_cv_header_bluetooth_bluetooth_h=no
	use gdbm      || disable+=" gdbm"
	use ncurses   || disable+=" _curses _curses_panel"
	use readline  || disable+=" readline"
	use sqlite    || disable+=" _sqlite3"
	use ssl       || export PYTHON_DISABLE_SSL="1"
	use tk        || disable+=" _tkinter"
	use xml       || disable+=" _elementtree pyexpat" # _elementtree uses pyexpat.
	export PYTHON_DISABLE_MODULES="${disable}"

	if ! use xml; then
		ewarn "You have configured Python without XML support."
		ewarn "This is NOT a recommended configuration as you"
		ewarn "may face problems parsing any XML documents."
	fi

	if [[ -n "${PYTHON_DISABLE_MODULES}" ]]; then
		einfo "Disabled modules: ${PYTHON_DISABLE_MODULES}"
	fi

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv
	fi

	filter-flags -malign-double

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	if tc-is-cross-compiler; then
		# Force some tests that try to poke fs paths.
		export ac_cv_file__dev_ptc=no
		export ac_cv_file__dev_ptmx=yes
	fi

	# Export CXX so it ends up in /usr/lib/${PN}2.X/config/Makefile.
	tc-export CXX
	# The configure script fails to use pkg-config correctly.
	# http://bugs.${PN}.org/issue15506
	export ac_cv_path_PKG_CONFIG=$(tc-getPKG_CONFIG)

	# Set LDFLAGS so we link modules with -l${PN}2.7 correctly.
	# Needed on FreeBSD unless Python 2.7 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	# LTO needs this
	if use lto; then
		append-ldflags "${CFLAGS}"
	fi

	local dbmliborder
	if use gdbm; then
		dbmliborder+="${dbmliborder:+:}gdbm"
	fi
	if use berkdb; then
		dbmliborder+="${dbmliborder:+:}bdb"
	fi

	local myeconfargs=(
		# The check is broken on clang, and gives false positive:
		# https://bugs.gentoo.org/596798
		# (upstream dropped this flag in 3.2a4 anyway)
		ac_cv_opt_olimit_ok=no
		# glibc-2.30 removes it; since we can't cleanly force-rebuild
		# Python on glibc upgrade, remove it proactively to give
		# a chance for users rebuilding ${PN} before glibc
		ac_cv_header_stropts_h=no

		--with-fpectl
		--enable-shared
		$(use_enable ipv6)
		$(use_with threads)
		$(use wide-unicode && echo "--enable-unicode=ucs4" || echo "--enable-unicode=ucs2")
		$(use_enable pgo optimizations)
		$(use_with lto)
		--infodir='${prefix}/share/info'
		--mandir='${prefix}/share/man'
		--with-computed-gotos
		--with-dbmliborder="${dbmliborder}"
		--with-libc=
		--enable-loadable-sqlite-extensions
		--with-system-expat
		--with-system-ffi
		--without-ensurepip
	)

	OPT="" econf "${myeconfargs[@]}"

	if use threads && grep -q "#define POSIX_SEMAPHORES_NOT_ENABLED 1" pyconfig.h; then
		eerror "configure has detected that the sem_open function is broken."
		eerror "Please ensure that /dev/shm is mounted as a tmpfs with mode 1777."
		die "Broken sem_open function (bug 496328)"
	fi
}

src_compile() {
	# Ensure sed works as expected
	# https://bugs.gentoo.org/594768
	use l10n_et-EE && local -x LC_ALL=C

	if use pgo; then
		# disable distcc and ccache
		export DISTCC_HOSTS=""
		export CCACHE_DISABLE=1
	fi

	# Avoid invoking pgen for cross-compiles.
	touch Include/graminit.h Python/graminit.c

	# extract the number of parallel jobs in MAKEOPTS
	echo ${MAKEOPTS} | egrep -o '(\-j|\-\-jobs)(=?|[[:space:]]*)[[:digit:]]+' > /dev/null
	if [ $? -eq 0 ]; then
		par_arg="-j$(echo ${MAKEOPTS} | egrep -o '(\-j|\-\-jobs)(=?|[[:space:]]*)[[:digit:]]+' | tail -n1 | egrep -o '[[:digit:]]+')"
	else
		par_arg=""
	fi
	export par_arg

	emake EXTRATESTOPTS="${par_arg} -uall,-audio -x test_distutils"

	# Work around bug 329499. See also bug 413751 and 457194.
	if has_version dev-libs/libffi[pax_kernel]; then
		pax-mark E ${PN}
	else
		pax-mark m ${PN}
	fi
}

src_test() {
	# Tests will not work when cross compiling.
	if tc-is-cross-compiler; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	# Skip failing tests.
	local skipped_tests="distutils gdb curses xpickle bdb runpy test_support"

	for test in ${skipped_tests}; do
		mv "${S}"/Lib/test/test_${test}.py "${T}"
	done

	# bug 660358
	local -x COLUMNS=80

	# Daylight saving time problem
	# https://bugs.${PN}.org/issue22067
	# https://bugs.gentoo.org/610628
	local -x TZ=UTC

	# Rerun failed tests in verbose mode (regrtest -w).
	emake test EXTRATESTOPTS="-w -uall,-audio ${par_arg}" < /dev/tty
	local result="$?"

	for test in ${skipped_tests}; do
		mv "${T}/test_${test}.py" "${S}"/Lib/test
	done

	elog "The following tests have been skipped:"
	for test in ${skipped_tests}; do
		elog "test_${test}.py"
	done

	elog "If you would like to run them, you may:"
	elog "cd '${EPREFIX}/usr/$(get_libdir)/${PN}2.7/test'"
	elog "and run the tests separately."

	if [[ ${result} -ne 0 ]]; then
		die "emake test failed"
	fi
}

src_install() {
	local libdir=${ED}/usr/$(get_libdir)/${PN}2.7

	emake DESTDIR="${D}" altinstall

	sed -e "s/\(LDFLAGS=\).*/\1/" -i "${libdir}/config/Makefile" || die "sed failed"

	# Fix collisions between different slots of Python.
	mv "${ED}/usr/bin/2to3" "${ED}/usr/bin/2to3-2.7" || die
	mv "${ED}/usr/bin/pydoc" "${ED}/usr/bin/pydoc2.7" || die
	mv "${ED}/usr/bin/idle" "${ED}/usr/bin/idle2.7" || die
	rm "${ED}/usr/bin/smtpd.py" || die

	use berkdb || rm -r "${libdir}/"{bsddb,dbhash.py*,test/test_bsddb*} || die
	use sqlite || rm -r "${libdir}/"{sqlite3,test/test_sqlite*} || die
	use tk || rm -r "${ED}/usr/bin/idle2.7" "${libdir}/"{idlelib,lib-tk} || die
	use elibc_uclibc && rm -fr "${libdir}/"{bsddb/test,test}

	use threads || rm -r "${libdir}/multiprocessing" || die
	use wininst || rm "${libdir}/distutils/command/"wininst-*.exe || die

	dodoc Misc/{ACKS,HISTORY,NEWS}

	if use examples; then
		docinto examples
		dodoc -r Tools
	fi
	insinto /usr/share/gdb/auto-load/usr/$(get_libdir) #443510
	local libname=$(printf 'e:\n\t@echo $(INSTSONAME)\ninclude Makefile\n' | \
		emake --no-print-directory -s -f - 2>/dev/null)
	newins "${S}"/Tools/gdb/lib${PN}.py "${libname}"-gdb.py

	newconfd "${FILESDIR}/pydoc.conf" pydoc-2.7
	newinitd "${FILESDIR}/pydoc.init" pydoc-2.7
	sed \
		-e "s:@PYDOC_PORT_VARIABLE@:PYDOC2_7_PORT:" \
		-e "s:@PYDOC@:pydoc2.7:" \
		-i "${ED}/etc/conf.d/pydoc-2.7" \
		"${ED}/etc/init.d/pydoc-2.7" || die "sed failed"

	local -x EPYTHON=${PN}2.7
	# if not using a cross-compiler, use the fresh binary
	if ! tc-is-cross-compiler; then
		local -x PYTHON=./${PN}
		local -x LD_LIBRARY_PATH=${LD_LIBRARY_PATH+${LD_LIBRARY_PATH}:}${PWD}
	else
		local -x PYTHON=${EPREFIX}/usr/bin/${EPYTHON}
	fi

	echo "EPYTHON='${PN}2.7'" > e${PN}.py || die
	${PN}_domodule e${PN}.py

	# ${PN}-exec wrapping support
	local scriptdir=${D}${PN}2.7
	mkdir -p "${scriptdir}" || die
	# ${PN}
	ln -s "../../../bin/${PN}2.7" "${scriptdir}/${PN}" || die
	# ${PN}-config
	ln -s "../../../bin/${PN}2.7-config" "${scriptdir}/${PN}-config" || die
	# 2to3, pydoc, pyvenv
	ln -s "../../../bin/2to3-2.7" "${scriptdir}/2to3" || die
	ln -s "../../../bin/pydoc2.7" "${scriptdir}/pydoc" || die
	# idle
	if use tk; then
		ln -s "../../../bin/idle2.7" "${scriptdir}/idle" || die
	fi
}

eselect_python_update() {
	if [[ -z "$(eselect ${PN} show)" || ! -f "${EROOT}/usr/bin/$(eselect ${PN} show)" ]]; then
		eselect ${PN} update
	fi

	if [[ -z "$(eselect ${PN} show --${PN}${PV%%.*})" || ! -f "${EROOT}/usr/bin/$(eselect ${PN} show --${PN}${PV%%.*})" ]]
	then
		eselect ${PN} update --${PN}${PV%%.*}
	fi
}

pkg_postinst() {
	eselect_${PN}_update
}

pkg_postrm() {
	eselect_${PN}_update
}
