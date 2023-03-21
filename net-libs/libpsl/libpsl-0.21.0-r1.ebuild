# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_{5..9}} )
inherit multilib-minimal python-any-r1

DESCRIPTION="C library for the Public Suffix List"
HOMEPAGE="https://rockdaboot.github.io/${PN}"
SRC_URI="https://github.com/rockdaboot/${PN}/releases/download/${P}/${P}.tar.lz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ppc ppc64 ~riscv s390 sparc x86"
IUSE="doc icu +idn +man static-libs nls +rpath"

RDEPEND="sys-devel/libtool
	icu? ( !idn? ( dev-libs/icu:=[${MULTILIB_USEDEP}] ) )
	idn? (
		dev-libs/libunistring[${MULTILIB_USEDEP}]
		net-dns/libidn2:=[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}
	doc? ( dev-util/gtk-doc-am )
	sys-devel/gettext
	virtual/pkgconfig
	man? ( dev-libs/libxslt )
"

pkg_pretend() {
	if use icu && use idn ; then
		ewarn "\"icu\" and \"idn\" USE flags are enabled."
		ewarn "Using \"idn\"."
	fi
}

multilib_src_configure() {
	local myeconfargs=(
		--disable-asan
		--disable-cfi
		--disable-ubsan
		$(use_enable doc gtk-doc)
		$(use_enable doc gtk-doc-html)
		$(use_enable doc gtk-doc-pdf)
		$(use_enable man)
		$(use_enable static-libs static)
		$(use_enable nls)
		$(use_enable rpath)
	)

	# Prefer idn even if icu is in USE as well
	if use idn ; then
		myeconfargs+=(
			--enable-builtin=libidn2
			--enable-runtime=libidn2
		)
	elif use icu ; then
		myeconfargs+=(
			--enable-builtin=libicu
			--enable-runtime=libicu
		)
	else
		myeconfargs+=( --disable-runtime )
	fi

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install() {
	default

	find "${ED}" -type f -name "*.la" -delete || die
}
