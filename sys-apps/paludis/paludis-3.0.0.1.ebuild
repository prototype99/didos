# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{7,8}} )
RUBY_VER=2.4

inherit bash-completion-r1 cmake-utils python-single-r1 user

DESCRIPTION="${PN}, the other package mangler"
HOMEPAGE="http://paludis.exherbo.org/"
SRC_URI="https://github.com/prototype99/${PN}/archive/v${PV}.tar.gz"

IUSE="doc pbins pink python ruby ruby_targets_ruby${RUBY_VER/./} search-index test +xml"
LICENSE="GPL-2 vim"
SLOT="0"
KEYWORDS="amd64"

COMMON_DEPEND="
	>=app-admin/eselect-1.2.13
	>=app-shells/bash-3.2:0
	dev-libs/libpcre:=[cxx]
	sys-apps/file:=
	pbins? ( >=app-arch/libarchive-3.1.2:= )
	python? (
		${PYTHON_DEPS}
		>=dev-libs/boost-1.67.0:=[python] )
	ruby? ( dev-lang/ruby:${RUBY_VER} )
	search-index? ( >=dev-db/sqlite-3:= )
	xml? ( >=dev-libs/libxml2-2.6:= )"

DEPEND="${COMMON_DEPEND}
	>=app-text/asciidoc-8.6.3
	app-text/htmltidy
	app-text/xmlto
	>=sys-devel/gcc-4.7
	doc? (
		app-doc/doxygen
		python? ( dev-python/sphinx )
		ruby? ( dev-ruby/syntax[ruby_targets_ruby${RUBY_VER/./}] )
	)
	virtual/pkgconfig
	test? ( >=dev-cpp/gtest-1.6.0-r1 )"

RDEPEND="${COMMON_DEPEND}
	sys-apps/sydbox"

PDEPEND="app-eselect/eselect-package-manager"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )
	ruby? ( ruby_targets_ruby${RUBY_VER/./} )"
RESTRICT="!test? ( test )"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != buildonly ]]; then
		if id ${PN}build >/dev/null 2>/dev/null ; then
			if ! groups ${PN}build | grep --quiet '\<tty\>' ; then
				eerror "The '${PN}build' user is now expected to be a member of the"
				eerror "'tty' group. You should add the user to this group before"
				eerror "upgrading ${PN}."
				die "Please add ${PN}build to tty group"
			fi
		fi
	fi
}

pkg_setup() {
	enewgroup "${PN}build"
	enewuser "${PN}build" -1 -1 "/var/tmp/${PN}" "${PN}build,tty"

	use python && python-single-r1_pkg_setup
}

src_prepare() {
	# Fix the script shebang on Ruby scripts.
	# https://bugs.gentoo.org/show_bug.cgi?id=439372#c2
	sed -i -e "1s/ruby/&${RUBY_VER/./}/" ruby/demos/*.rb || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_DOXYGEN=$(usex doc)
		-DENABLE_GTEST=$(usex test)
		-DENABLE_PBINS=$(usex pbins)
		-DENABLE_PYTHON=$(usex python)
		-DENABLE_PYTHON_DOCS=$(usex doc) # USE=python implicit
		-DENABLE_RUBY=$(usex ruby)
		-DENABLE_RUBY_DOCS=$(usex doc) # USE=ruby implicit
		-DENABLE_SEARCH_INDEX=$(usex search-index)
		-DENABLE_VIM=ON
		-DENABLE_XML=$(usex xml)

		-DPALUDIS_COLOUR_PINK=$(usex pink)
		-DRUBY_VERSION=${RUBY_VER}
		-DPALUDIS_ENVIRONMENTS=all
		-DPALUDIS_DEFAULT_DISTRIBUTION=gentoo
		-DPALUDIS_CLIENTS=all
		-DCONFIG_FRAMEWORK=eselect

		# GNUInstallDirs
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	dobashcomp bash-completion/cave

	insinto /usr/share/zsh/site-functions
	doins zsh-completion/_cave
}

src_test() {
	# Work around Portage bugs
	local -x PALUDIS_DO_NOTHING_SANDBOXY="portage sucks"
	local -x BASH_ENV=/dev/null

	if [[ ${EUID} == 0 ]] ; then
		# hate
		local -x PALUDIS_REDUCED_UID=0
		local -x PALUDIS_REDUCED_GID=0
	fi

	cmake-utils_src_test
}

pkg_postinst() {
	local pm
	if [[ -f ${ROOT}/etc/env.d/50package-manager ]] ; then
		pm=$( source "${ROOT}"/etc/env.d/50package-manager ; echo "${PACKAGE_MANAGER}" )
	fi

	if [[ ${pm} != paludis ]] ; then
		elog "If you are using paludis or cave as your primary package manager,"
		elog "you should consider running:"
		elog "    eselect package-manager set paludis"
	fi
}