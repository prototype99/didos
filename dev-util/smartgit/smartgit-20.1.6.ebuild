# Copyright 2015-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

## EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

## functions: newicon, domenu
inherit desktop

DESCRIPTION="Git client with support for GitHub Pull Requests+Comments, SVN and Mercurial"
HOMEPAGE_A=(
	"https://www.syntevo.com/${PN,,}"
)
LICENSE_A=(
	"${PN}"
)

# slot number is based on the upstream slotting mechanism which creates a new subdir
# in `~/.smartgit/` for each new major release. The subdir name corresponds with SLOT.
PV_MAJ="$(ver_cut 1)"
PV_MIN="$(ver_cut 2)"
SLOT="${PV_MAJ}$( (( PV_MIN )) && echo ".${PV_MIN}" )"
MY_PNS="${PN}${SLOT%%/*}"

SRC_URI="https://www.syntevo.com/downloads/${PN}/archive/${PN}-linux-20_1_6.tar.gz -> ${P}.tar.gz"

# can be used on any 64-bit architecture supported by Linux, but the bundled JRE is for x86_64 only
KEYWORDS="-* ~amd64"
IUSE_A=( )

RDEPEND_A=(
)

RESTRICT+=" mirror strip"

inherit arrays

S="${WORKDIR}/${PN}"

src_prepare()
{
	eapply_user

	xdg_src_prepare
}

src_install()
{
	local -r -- vendor_ns="syntevo"
	local -r -- install_dir="/opt/${vendor_ns}/${MY_PNS}"

	## remove files not needed
	NO_V=1 rrm -r licenses jre/legal
	rrm bin/{add,remove}-menuitem.sh

	# remove executable bit
	find -type f -executable -print0 | xargs -0 chmod --changes a-x
	assert

	## make scripts and java executable
	rchmod a+x {bin,lib}/*.sh jre/bin/*

	## install entrypoint
	rcp "${FILESDIR}"/${PN,,}.sh "bin/"
	rdosym --rel -- "${install_dir}/bin/${PN}.sh" "/usr/bin/${MY_PNS}"

	## install icons
	newicon -s 'scalable' "bin/${PN,,}.svg" "${MY_PNS}.png"
	local -i s
	for s in 32 48 64 128 256
	do
		newicon -s ${s} "bin/${PN,,}-${s}.png" "${MY_PNS}.png"
	done
	rrm bin/*.{png,svg}

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
	rmkdir "${ED}${install_dir}"
	rmv --strip-trailing-slashes --no-target-directory "${S}" "${ED}${install_dir}"
}
