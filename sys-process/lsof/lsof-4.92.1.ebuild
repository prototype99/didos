# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: append-ldflags, append-cppflags
inherit flag-o-matic
## functions: tc-getCC, tc-getPKG_CONFIG
inherit toolchain-funcs

DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="https://people.freebsd.org/~abe/"
LICENSE="lsof"

MY_P="${P/-/_}_src"
SLOT="0"
SRC_URI_A=(
	"https://github.com/lsof-org/lsof/archive/refs/tags/${PV}.tar.gz"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( examples ipv6 rpc selinux static )

CDEPEND_A=(
	"rpc? ( net-libs/libtirpc )
	selinux? ( sys-libs/libselinux )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"rpc? ( virtual/pkgconfig )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}/${MY_P}"

src_prepare() {
	eapply "${FILESDIR}"/${PN}-4.85-cross.patch #432120
	eapply_user

	# fix POSIX compliance with `echo`
	rsed -e 's:echo -n:printf:' \
		-i -- AFSConfig Configure Customize Inventory tests/CkTestDB
	# Convert `test -r header.h` into a compile test.
	# Make sure we convert `test ... -a ...` into two `test` commands
	# so we can then convert both over into a compile test. #601432
	rsed -E \
		-e '/if test .* -a /s: -a : \&\& test :g' \
		-e '/test -r/s:test -r \$\{LSOF_INCLUDE\}/([[:alnum:]/._]*):echo "#include <\1>" | ${LSOF_CC} ${LSOF_CFGF} -E - >/dev/null 2>\&1:g' \
		-e 's:grep (.*) \$\{LSOF_INCLUDE\}/([[:alnum:]/._]*):echo "#include <\2>" | ${LSOF_CC} ${LSOF_CFGF} -E -P -dD - 2>/dev/null | grep \1:' \
		-i -- Configure
}

src_configure() {
	use static && \
		append-ldflags -static

	append-cppflags $(use rpc && $(tc-getPKG_CONFIG) libtirpc --cflags || echo "-DHASNOTRPC -DHASNORPC_H")
	append-cppflags $(usex ipv6 -{D,U}HASIPv6)

	export LSOF_CFGL="${CFLAGS} ${LDFLAGS} $(use rpc && $(tc-getPKG_CONFIG) libtirpc --libs)"

	# Set LSOF_INCLUDE to a dummy location so the script doesn't poke
	# around in it and mix /usr/include paths with cross-compile/etc.
	touch .neverInv
	export LINUX_HASSELINUX=$(usex selinux y n)
	export LSOF_INCLUDE=${T}
	export LSOF_CC=$(tc-getCC)
	export LSOF_AR="$(tc-getAR) rc"
	export LSOF_RANLIB=$(tc-getRANLIB)
	export LSOF_CFGF="${CFLAGS} ${CPPFLAGS}"
	./Configure -n linux || die
}

src_compile() {
	emake DEBUG="" all
}

src_install() {
	dobin "${PN}"
	doman "${PN}.8"

	if use examples ; then
		insinto /usr/share/lsof/scripts
		doins scripts/*
	fi

	dodoc 00*
}
