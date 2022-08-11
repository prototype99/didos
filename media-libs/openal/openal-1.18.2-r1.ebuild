# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:kcat:openal-soft"
GH_REF="openal-soft-${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
## functions: make_desktop_entry
inherit desktop
## functions: dohelp2man
inherit help2man

DESCRIPTION="Software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html ${GH_HOMEPAGE}"
LICENSE="LGPL-2+"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
backends=( alsa coreaudio jack oss portaudio pulseaudio )
IUSE_A=(
	${backends[@]}
	debug examples gui tests utils
	cpu_flags_x86_{sse,sse2,sse3,sse4_1} cpu_flags_arm_neon
)

CDEPEND_A=(
	"alsa? ( media-libs/alsa-lib )"
	"jack? ( virtual/jack )"
	"portaudio? ( media-libs/portaudio )"
	"pulseaudio? ( media-sound/pulseaudio )"
	"gui? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5"
	")"

	"examples? ("
		"media-libs/libsdl2[sound]"
		"media-video/ffmpeg"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"oss? ( virtual/os-headers )"
	"utils? ( sys-apps/help2man )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	# at least one backend must be selected otherwise it segfaults
# 	"|| ( ${backends[*]} )"
	# IF(ALSOFT_UTILS AND NOT ALSOFT_NO_CONFIG_UTIL) add_subdirectory(utils/alsoft-config)
	"gui? ( utils )"
)

inherit arrays

# upstream uses this pre-created dir
BUILD_DIR="${S}/build"

src_prepare() {
	eapply "${FILESDIR}"/1.17.2-disable_pulseaudio_auto_spawn.patch
	eapply_user

	xdg_src_prepare
	cmake_src_prepare
}

src_configure() {
		local mycmakeargs=(
			# for dynamicly loading backend libs
			-D "ALSOFT_DLOPEN=ON"
			-D "ALSOFT_WERROR=OFF"
			# Build and install utility programs
			-D "ALSOFT_UTILS=$(usex utils)"
			# Disable building the alsoft-config utility
			-D "ALSOFT_NO_CONFIG_UTIL=$(usex '!gui')"

			-D "ALSOFT_EXAMPLES=$(usex examples)"
			-D "ALSOFT_TESTS=$(usex tests)"

			# alsoft.conf sample configuration file
			-D "ALSOFT_CONFIG=ON"
			# HRTF definition files
			-D "ALSOFT_HRTF_DEFS=ON"
			# AmbDec preset files
			-D "ALSOFT_AMBDEC_PRESETS=ON"
			# install headers and libs, executables only otherwise
			-D "ALSOFT_INSTALL=ON"

			-D ALSOFT_{REQUIRE,BACKEND}_ALSA=$(usex alsa)
			-D ALSOFT_{REQUIRE,BACKEND}_OSS=$(usex oss)
			# SOLARIS # skipped
			# SNDIO # skipped
			# QSA # skipped
			# Windows-only # skipped
			-D ALSOFT_{REQUIRE,BACKEND}_PORTAUDIO=$(usex portaudio)
			-D ALSOFT_{REQUIRE,BACKEND}_PULSEAUDIO=$(usex pulseaudio)
			-D ALSOFT_{REQUIRE,BACKEND}_JACK=$(usex jack)
			-D ALSOFT_{REQUIRE,BACKEND}_COREAUDIO=$(usex coreaudio)
			# OpenSL (Android) # skipped
			# SDL2 # skipped
			-D ALSOFT_BACKEND_WAVE=ON # Wave File Writer

			-D ALSOFT_{REQUIRE,CPUEXT}_SSE=$(usex cpu_flags_x86_sse)
			-D ALSOFT_{REQUIRE,CPUEXT}_SSE2=$(usex cpu_flags_x86_sse2)
			# broken upstream, https://github.com/kcat/openal-soft/issues/195
			-D ALSOFT_{REQUIRE,CPUEXT}_SSE3=$(usex cpu_flags_x86_sse3)
			-D ALSOFT_{REQUIRE,CPUEXT}_SSE4_1=$(usex cpu_flags_x86_sse4_1)
			-D ALSOFT_{REQUIRE,CPUEXT}_NEON=$(usex cpu_flags_arm_neon)

			-D "ALSOFT_EMBED_HRTF_DATA=OFF"
		)

		cmake_src_configure
}

src_install() {
	DOCS=( alsoftrc.sample docs/env-vars.txt docs/hrtf.txt ChangeLog README )

	cmake_src_install

	local b h2m_bins=()
	use tests && h2m_bins+=( altonegen )
	use utils && h2m_bins+=( makehrtf openal-info )
	for b in "${h2m_bins[@]}" ; do
		local H2M_NO_DEFAULT_HELP_OPTION=1
		dohelp2man "build/${b}"
	done

	# NOTE: alsoft.conf doesn't support PREFIX, needs patching in ${S}/Alc/alcConfig.c
	insinto /etc/openal
	newins alsoftrc.sample alsoft.conf

	if use gui ; then
		local make_desktop_entry_args=(
			"${EPREFIX}"/usr/bin/alsoft-config	# exec
			"OpenAL Soft Configuration"	# name
			settings-configure	# icon
			"Settings;HardwareSettings;Audio;AudioVideo;"	# categories
		)
		local make_desktop_entry_extras=(  )
		make_desktop_entry "${make_desktop_entry_args[@]}" \
			"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
	fi
}
