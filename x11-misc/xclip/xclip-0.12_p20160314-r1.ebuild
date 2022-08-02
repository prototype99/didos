EAPI=6

inherit autotools

COMMIT_HASH=0a1bbcc10d1a17969587d5995e4d47ca543a129c

DESCRIPTION="Command-line utility to read data from standard in and place it in an X selection"
HOMEPAGE="https://github.com/astrand/xclip"
SRC_URI="https://github.com/astrand/xclip/archive/${COMMIT_HASH}.tar.gz"
S="${WORKDIR}/xclip-${COMMIT_HASH}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXmu"
DEPEND="${RDEPEND}
	x11-libs/libXt"

src_prepare() {
	eautoreconf
}

src_configure() {
    econf
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc ChangeLog README
}
