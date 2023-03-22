# Copyright 2015-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit desktop xdg

DESCRIPTION="Git client with support for GitHub Pull Requests+Comments, SVN and Mercurial"
HOMEPAGE="https://www.syntevo.com/${PN,,}"
LICENSE="${PN}"

# slot number is based on the upstream slotting mechanism which creates a new subdir
# in `~/.smartgit/` for each new major release. The subdir name corresponds with SLOT.
PV_MAJ="$(ver_cut 1)"
PV_MIN="$(ver_cut 2)"
SLOT="${PV_MAJ}$( (( PV_MIN )) && echo ".${PV_MIN}" )"
MY_PNS="${PN}${SLOT%%/*}"

SRC_URI="https://www.syntevo.com/downloads/${PN}/archive/${PN}-linux-20_2_6.tar.gz -> ${P}.tar.gz"

KEYWORDS="amd64 ~arm64"
IUSE="+kernel +system-jre vanilla"

REQUIRED_USE="arm64? ( system-jre )
	vanilla? ( !kernel !system-jre )"

RDEPEND="system-jre? ( >=virtual/jre-11 )"

RESTRICT+=" mirror strip"

S="${WORKDIR}/${PN}"

src_prepare()
{
	use vanilla || eapply "${FILESDIR}/fast-start${PV}".patch
	use system-jre && eapply "${FILESDIR}/system-jre${PV}".patch
	use kernel && eapply "${FILESDIR}/kernel${PV}".patch
	default

	xdg_src_prepare
}

src_install()
{
	local -r -- vendor_ns="syntevo"
	local -r -- install_dir="/opt/${vendor_ns}/${MY_PNS}"

	## remove files not needed
	NO_V=1 rm -r licenses jre/legal
	rm bin/{add,remove}-menuitem.sh

	# remove executable bit
	find -type f -executable -print0 | xargs -0 chmod --changes a-x
	assert

	## make scripts and java executable
	chmod a+x {bin,lib}/*.sh jre/bin/*

	## install entrypoint
	dosym "${install_dir}/bin/${PN}.sh" "/usr/bin/${MY_PNS}"

	## install icons
	newicon -s 'scalable' "bin/${PN,,}.svg" "${MY_PNS}.png"
	local -i s
	for s in 32 48 64 128 256
	do
		newicon -s ${s} "bin/${PN,,}-${s}.png" "${MY_PNS}.png"
	done
	rm bin/*.{png,svg}

	local -- dme_file="${T}/${PN,,}_${SLOT%%/*}.desktop"
	cat <<-_EOF_ > "${dme_file}" || die
		[Desktop Entry]
		Type=Application
		Version=1.1
		Name=SmartGit ${SLOT%%/*}
		GenericName=Git GUI
		Comment=${DESCRIPTION}
		Icon=${MY_PNS}
		TryExec=${EPREFIX}${install_dir}/bin/${PN,,}.sh
		Exec=${EPREFIX}${install_dir}/bin/${PN,,}.sh %U
		Terminal=false
		MimeType=x-scheme-handler/git;x-scheme-handler/smartgit;x-scheme-handler/sourcetree;
		Categories=Development;RevisionControl;
		Keywords=git;svn;hg;mercurial;github;bitbucket;
		StartupWMClass=SmartGit
	_EOF_
	domenu "${dme_file}"

	## move files to the install image
	mkdir --parents "${ED}${install_dir}" || die "target destination creation failed"
	mv --strip-trailing-slashes --no-target-directory "${S}" "${ED}${install_dir}"
}
