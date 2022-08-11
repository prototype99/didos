# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="v${PV}"

## functions: dsf:eval
inherit dsf-utils

## functions: rindeal:prefix_flags
inherit rindeal-utils

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake

DESCRIPTION="Linkable library implementation of Git"
HOMEPAGE="${GH_HOMEPAGE} https://libgit2.github.com/"
LICENSE="GPL-2-with-linking-exception"

SLOT="0/$(ver_cut 2)"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( debug +curl examples gssapi +ssh test +threads trace +https
	"$(rindeal:prefix_flags \
		sha1_ \
			generic +openssl collision_detection)"
)

CDEPEND_A=(
	# used for https as well as for SHA1 crypto if chosen
	"$(dsf:eval \
		'sha1_openssl|https' \
			"dev-libs/openssl:0=")"
	"sys-libs/zlib"
	"=net-libs/http-parser-2*:="
	"curl? ( net-misc/curl:= )"
	"gssapi? ( virtual/krb5 )"
	"ssh? ( net-libs/libssh2 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"^^ ( $(rindeal:prefix_flags \
		sha1_ \
			generic openssl collision_detection) )"
)
RESTRICT+=""

inherit arrays

src_configure() {
	local mycmakeargs=(
		-D LIB_INSTALL_DIR="${EPREFIX}/usr/$(get_libdir)"

		-D SONAME=ON
		-D BUILD_SHARED_LIBS=ON  # OFF for static
		-D THREADSAFE=$(usex threads)
		-D BUILD_CLAR=$(usex test)
		-D BUILD_EXAMPLES=OFF
		-D TAGS=OFF  # ctags
		-D PROFILE=OFF
		-D ENABLE_TRACE=$(usex trace)
		-D LIBGIT2_FILENAME=OFF
		-D SHA1_BACKEND=$(usex sha1_generic "Generic" $(usex sha1_openssl "OpenSSL" $(usex sha1_collision_detection "CollisionDetection" "die")))
		-D USE_SSH=$(usex ssh)
		-D USE_HTTPS="OpenSSL"
		-D USE_GSSAPI=$(usex gssapi)
		-D VALGRIND=$(usex debug)
		-D CURL=$(usex curl)
		-D USE_EXT_HTTP_PARSER=ON
		-D DEBUG_POOL=$(usex debug)
		-D ENABLE_WERROR=OFF
		-D USE_BUNDLED_ZLIB=OFF
		-D ENABLE_REPRODUCIBLE_BUILDS=OFF
	)
	cmake_src_configure
}

src_test() {
	if [[ ${EUID} -eq 0 ]]
	then
		# repo::iterator::fs_preserves_error fails if run as root
		# since root can still access dirs with 0000 perms
		ewarn "Skipping tests: non-root privileges are required for all tests to pass"
	else
		local TEST_VERBOSE=1
		cmake-utils_src_test
	fi
}

src_install() {
	DOCS=( AUTHORS CONTRIBUTING.md CONVENTIONS.md README.md )

	cmake_src_install

	if use examples
	then
		find examples -name '.gitignore' -delete || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
