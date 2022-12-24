# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="REL_${PV//./_}"

## python-*.eclass:
# The selftests fail with pypy, and urlgrabber segfaults for me.
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all, distutils-r1_python_compile, distutils-r1_python_install_all
## variables: PYTHON_DEPS, PYTHON_REQUIRED_USE
inherit distutils-r1

DESCRIPTION="Python interface to libcurl"
HOMEPAGE="
	${GH_HOMEPAGE}
	https://pypi.python.org/pypi/pycurl
	http://pycurl.io/"
LICENSE="LGPL-2.1"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	doc test examples
	ssl ssl_gnutls ssl_nss +ssl_openssl
)

CDEPEND_A=(
	"${PYTHON_DEPS}"

	# If the libcurl ssl backend changes pycurl should be recompiled.
	"net-misc/curl:0=[ssl=]"
	"ssl? ("
		# Depend on a curl with ssl_* USE flags.
		# libcurl must not be using an ssl backend we do not support.
		"net-misc/curl[ssl_gnutls(-)?,ssl_nss(-)?,ssl_openssl(-)?]"

		# If curl uses gnutls, depend on at least gnutls 2.11.0 so that pycurl
		# does not need to initialize gcrypt threading and we do not need to
		# explicitly link to libgcrypt.
		"ssl_gnutls? ( >=net-libs/gnutls-2.11.0 )"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"${PYTHON_REQUIRED_USE}"
	"ssl? ( ^^ ( ssl_openssl ssl_gnutls ssl_nss ) )"
)

inherit arrays

python_prepare_all() {
	# do not install docs, examples and other unneeded stuff
	rsed -e "/setup_args\['data_files'\] = /d" -i -- setup.py

	distutils-r1_python_prepare_all
}

python_compile() {
	python_is_python3 || local -x CFLAGS="${CFLAGS} -fno-strict-aliasing"

	# prepares headers and fixes docstrings
	emake gen

	local mydistutilsargs=(
		$(usex ssl_openssl "--with-openssl" "")
		$(usex ssl_gnutls "--withgnutls" "")
		$(usex ssl_nss "--with-nss" "")
	)

	distutils-r1_python_compile
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/. )
	use examples && local EXAMPLES=( examples/. )

	distutils-r1_python_install_all
}
