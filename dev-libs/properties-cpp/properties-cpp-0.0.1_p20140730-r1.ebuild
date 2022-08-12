# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="A very simple convenience library for handling properties and signals in C++11"
HOMEPAGE="https://launchpad.net/properties-cpp"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/p/${PN}/${PN}_0.0.1+14.10.20140730.orig.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-0.0.1+14.10.20140730"

src_prepare() {
	sed -i '/add_subdirectory(tests)/d' CMakeLists.txt
	eapply_user
}
