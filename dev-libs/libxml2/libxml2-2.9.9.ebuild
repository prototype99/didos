# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# TODO: revamp ebuild and sync eith actual upstream state

## git-hosting.eclass:
GH_RN="github:GNOME"
GH_REF="v${PV}"

## python-r1.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5,6,7}}} )
PYTHON_REQ_USE="xml"

# TODO order these
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: elibtoolize
inherit libtool
## functions: filter-flags
inherit flag-o-matic
## functions: prune_libtool_files
inherit ltprune
## variables: PYTHON_REQUIRED_USE, PYTHON_DEPS
## functions: python_foreach_impl, python_copy_sources
inherit python-r1
## functions: eautoreconf
inherit autotools
## functions: eprefixify
inherit prefix

DESCRIPTION="Version 2 of the library to manipulate XML files"
HOMEPAGE="http://www.xmlsoft.org/"
LICENSE="MIT"

SLOT="2"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	static-libs

	ipv6

	+c14n +catalog +debug +docbook fexceptions +ftp +history +html +http +iconv icu +iso8859x legacy mem_debug
	+output +pattern +push python +reader +readline +regexps run_debug +sax1 +schemas +schematron +threads
	thread-alloc +tree +valid +writer +xinclude +xpath +xptr +modules +zlib lzma
)

CDEPEND_A=(
	"icu? ( >=dev-libs/icu-51.2-r1:= )"
	"lzma? ( >=app-arch/xz-utils-5.0.5-r1:= )"
	"zlib? ( sys-libs/zlib )"
	"python? ( ${PYTHON_DEPS} )"
	"readline? ( sys-libs/readline:= )"
	"iconv? ( virtual/libiconv )"
	"history? ( sys-libs/ncurses:0 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	# `AC_PATH_PROG(PERL, perl, /usr/bin/perl)`
	"dev-lang/perl"
	# `AC_PATH_PROG(WGET, wget, /usr/bin/wget)`
	"net-misc/wget"
	# `AC_PATH_PROG(XSLTPROC, xsltproc, /usr/bin/xsltproc)`
	"dev-libs/libxslt"
	"dev-util/gtk-doc-am"
	# `PKG_PROG_PKG_CONFIG`
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	### configure.ac `hard dependancies on options` # yes, dancies
	"schemas? ( pattern regexps )"
	"schematron? ( pattern tree xpath )"
	"reader? ( push )"
	"xptr? ( xpath )"

	"history? ( readline )" # libhistory, libreadline
	"c14n? ( xpath )"
	"mem_debug? ( !thread-alloc )"
	"xinclude? ( xpath )"

	"python? ( ${PYTHON_REQUIRED_USE} )"
)

inherit arrays

S="${WORKDIR}/${PN}-${PV}"

src_prepare() {
	default

	# Patches needed for prefix support
	eapply "${FILESDIR}"/${PN}-2.7.1-catalog_path.patch

	eprefixify catalog.c xmlcatalog.c runtest.c xmllint.c

	# Fix python detection, bug #567066
	# https://bugzilla.gnome.org/show_bug.cgi?id=760458
	eapply "${FILESDIR}"/${PN}-2.9.2-python-ABIFLAG.patch

	## debian patches
	#eapply "${FILESDIR}/0003-python-remove-single-use-of-_PyVerify_fd.patch"
	#eapply "${FILESDIR}/0004-CVE-2017-8872.patch"

	rsed -r -e '/^(DIST_)?SUBDIRS/ s, (doc|example),,g' -i -- Makefile.am

	# Please do not remove, as else we get references to PORTAGE_TMPDIR
	# in /usr/lib/python?.?/site-packages/libxml2mod.la among things.
	# We now need to run eautoreconf at the end to prevent maintainer mode.
	elibtoolize

	eautoreconf

	python_copy_sources
}

src_configure() {
	# filter seemingly problematic CFLAGS (#26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	local my_default_econf_args=(
		--disable-rebuild-docs
		$(use_enable ipv6)
		$(use_enable static-libs static)

		$(use_with c14n)
		$(use_with catalog)
		$(use_with debug)
		$(use_with docbook)
		$(use_with fexceptions)
		$(use_with ftp)
		$(use_with history)
		$(use_with html)
		$(use_with http)
		$(use_with iso8859x)
		$(use_with legacy)
		$(use_with mem_debug)
# 		$(use_with minimum)
		$(use_with output)
		$(use_with pattern)
		$(use_with push)
		$(use_with python)
		$(use_with reader)
		$(use_with readline)
		$(use_with regexps)
		$(use_with run_debug)
		$(use_with sax1)
		$(use_with schemas)
		$(use_with schematron)
		$(use_with threads)
		$(use_with thread-alloc)
		$(use_with tree)
		$(use_with valid)
		$(use_with writer)
		$(use_with xinclude)
		$(use_with xpath)
		$(use_with xptr)
		$(use_with modules)
		$(use_with zlib)
		$(use_with lzma)
		$(use_with modules)
		$(use_with modules)
	)

	local econf_args=(
		"${my_default_econf_args[@]}"
		# build python bindings separately
		--without-python
	)
	econf "${econf_args[@]}"

	if use python ; then
		my_python_configure() {
			local econf_args=(
				"${my_default_econf_args[@]}" \
				# odd build system, also see bug gentoo#582130
				"--with-python=${ROOT%/}${PYTHON}"
			)
			run_in_build_dir \
				econf "${econf_args[@]}"
		}
		python_foreach_impl \
			my_python_configure
	fi
}

my_python_emake() {
	rpushd "${BUILD_DIR}/python"
	emake top_builddir="${S}" "$@"
	rpopd
}

src_compile() {
	default

	if use python ; then
		python_foreach_impl \
			my_python_emake all
	fi
}

src_install() {
	DOCS=( AUTHORS ChangeLog NEWS README* TODO* )

	emake DESTDIR="${D}" \
		EXAMPLES_DIR="${EPREFIX}"/usr/share/doc/${PF}/examples install

	if use python ; then
		python_foreach_impl my_python_emake \
			DESTDIR="${D}" \
			docsdir="${EPREFIX}"/usr/share/doc/${PF}/python \
			exampledir="${EPREFIX}"/usr/share/doc/${PF}/python/examples \
			install
		python_foreach_impl \
			python_optimize
	fi

	rrm -r "${ED}"/usr/share/doc/${P}
	einstalldocs

	prune_libtool_files --modules
}

pkg_postinst() {
	# need an XML catalog, so no-one writes to a non-existent one
	CATALOG="${EROOT}etc/xml/catalog"

	# we dont want to clobber an existing catalog though,
	# only ensure that one is there
	# <obz@gentoo.org>
	if [[ ! -e ${CATALOG} ]]; then
		[[ -d "${EROOT}etc/xml" ]] || rmkdir "${EROOT}etc/xml"
		"${EPREFIX}"/usr/bin/xmlcatalog --create > "${CATALOG}"
		einfo "Created XML catalog in ${CATALOG}"
	fi
}
