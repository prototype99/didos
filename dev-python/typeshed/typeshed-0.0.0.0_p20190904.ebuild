# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="python"
GITHUB_REF="3fc8aec" # mypy-0.730

inherit github

DESCRIPTION="Collection of library stubs for Python, with static types"
HOMEPAGE="${GITHUB_HOMEPAGE}"
LICENSE="Apache-2.0"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"

inherit arrays

src_unpack()
{
	github:src_unpack
}

src_configure() { :; }
src_compile() { :; }

src_install()
{
	dodoc README.md

	insinto /usr/share/${PN}
	doins -r stdlib third_party
}
