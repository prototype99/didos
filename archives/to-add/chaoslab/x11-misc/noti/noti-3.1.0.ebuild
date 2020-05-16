# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/variadico/noti"

inherit golang-vcs-snapshot

DESCRIPTION="Trigger notifications when a process completes"
HOMEPAGE="https://github.com/variadico/noti"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="pie test"

DOCS=( docs/{noti,release}.md )
QA_PRESTRIPPED="usr/bin/noti"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

RDEPEND="|| (
		x11-libs/libnotify
		app-accessibility/espeak
	)
"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w -X '${EGO_PN}/internal/command.Version=${PV}'"
	)
	go build "${mygoargs[@]}" ./cmd/noti || die

	if use test; then
		go install ./vendor/github.com/golang/lint/golint || die
		go install ./vendor/honnef.co/go/tools/cmd/megacheck || die
	fi
}

src_test() {
	local PATH="${G}/bin:$PATH"
	emake test
}

src_install() {
	dobin noti
	einstalldocs
}
