# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit eutils java-pkg-2

MY_PV="$(ver_rs 1- _)"
DESCRIPTION="MARS is a lightweight IDE for programming in MIPS assembly language"
HOMEPAGE="https://courses.missouristate.edu/KenVollmar/MARS/index.htm"
SRC_URI="https://courses.missouristate.edu/KenVollmar/MARS/MARS_${MY_PV}_Aug2014/Mars${MY_PV}.jar"

SLOT="0"
KEYWORDS="amd64 x86"
IUSE="java nls"

DEPEND=">=virtual/jdk-1.6:*"
RDEPEND=">=virtual/jre-1.6 ${DEPEND}"

S="${WORKDIR}"

src_compile() {
	jar cmf mainclass.txt Mars.jar PseudoOps.txt Config.properties Syscall.properties Settings.properties MARSlicense.txt mainclass.txt MipsXRayOpcode.xml registerDatapath.xml controlDatapath.xml ALUcontrolDatapath.xml CreateMarsJar.bat Mars.java Mars.class docs help images mars
}

src_install() {
	java-pkg_dojar Mars.jar
	java-pkg_dolauncher ${PN} -jar Mars.jar
}