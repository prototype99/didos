# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( py{py,thon{2_7,3_{5..8}}} )
DISTUTILS_OPTIONAL="1"
DISTUTILS_IN_SOURCE_BUILD="1"

# TODO: add jni wrapper support
JAVA_SRC_DIR="java"

inherit cmake-multilib distutils-r1 java-pkg-2 java-pkg-simple

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli"

SLOT="0/$(ver_cut 1)"

CDEPEND="python? ( ${PYTHON_DEPS} )"
RDEPEND="${CDEPEND}
	java? ( >=virtual/jre-1.7 )"
DEPEND="${CDEPEND}
	java? ( >=virtual/jdk-1.7 )"

IUSE="java python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

LICENSE="MIT python? ( Apache-2.0 )"

DOCS=( README.md CONTRIBUTING.md )

KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~x64-solaris"
SRC_URI="https://github.com/google/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="!test? ( test )"

S="${WORKDIR}/${P}"

pkg_setup() {
	use java && java-pkg-2_pkg_setup
}

src_prepare() {
	use python && distutils-r1_src_prepare
	cmake-utils_src_prepare
	if use java
	then
		find "${JAVA_SRC_DIR}" -name "*Test.java" -print -delete || die

		java-pkg-2_src_prepare
	fi
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING="$(usex test)"
	)
	cmake-utils_src_configure
}
src_configure() {
	cmake-multilib_src_configure
	use python && distutils-r1_src_configure
}

multilib_src_compile() {
	cmake-utils_src_compile
}
src_compile() {
	cmake-multilib_src_compile
	use python && distutils-r1_src_compile
	use java && java-pkg-simple_src_compile
}

python_test(){
	esetup.py test || die
}

multilib_src_test() {
	cmake-utils_src_test
}
src_test() {
	cmake-multilib_src_test
	use python && distutils-r1_src_test
}

multilib_src_install() {
	cmake-utils_src_install
}
multilib_src_install_all() {
	use python && distutils-r1_src_install
	use java && java-pkg-simple_src_install
}

pkg_preinst() {
	use java && java-pkg-2_pkg_preinst
}
