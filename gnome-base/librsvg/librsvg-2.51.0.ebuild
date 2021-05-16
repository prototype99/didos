# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"
VALA_USE_DEPEND="vapigen"

inherit gnome2 multilib-minimal rust-toolchain vala

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~sparc ~x86"

IUSE="debug gtk-doc +introspection tools vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=x11-libs/cairo-1.16.0[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.9:2[${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.20:2[introspection?,${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.50.0:2[${MULTILIB_USEDEP}]
	>=media-libs/harfbuzz-2.0.0:=[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4:2[${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.38.0[${MULTILIB_USEDEP}]

	introspection? ( >=dev-libs/gobject-introspection-0.10.8:= )
	tools? ( >=x11-libs/gtk+-3.10.0:3 )
"
DEPEND="${RDEPEND}
	>=virtual/rust-1.40[${MULTILIB_USEDEP}]
	dev-util/glib-utils
	>=sys-devel/gettext-0.19.8
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
	gtk-doc? ( >=dev-util/gtk-doc-1.13 )
	vala? ( $(vala_depend) )
"
# >=gtk-doc-am-1.13, gobject-introspection-common, vala-common needed by eautoreconf

RESTRICT="test" # Lots of issues on 32bit builds, 64bit build seems to get into an infinite compilation sometimes, etc.

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
	cat <<- _EOF_ > "${S}"/config.toml
		[profile.release]
		opt-level = 3
		debug = false
		debug-assertions = false
		overflow-checks = false
		lto = "thin"
		codegen-units = 1
	_EOF_
}

multilib_src_configure() {
	local myconf=(
		--disable-static
		$(use_enable debug)
		$(use_enable gtk-doc)
		$(use_enable tools)
		$(multilib_native_use_enable introspection)
		$(multilib_native_use_enable vala)
		--enable-pixbuf-loader
	)

	# -Bsymbolic is not supported by the Darwin toolchain
	if [[ ${CHOST} == *-darwin* ]]; then
		myconf+=( --disable-Bsymbolic )
	fi


	if tc-is-cross-compiler; then
		myconf+=(
			--host=${CHOST_default}
			RUST_TARGET="$(rust_abi)"
		)
	fi

	if ! multilib_is_native_abi; then
		myconf+=(
			# Set the rust target, which can differ from CHOST
			RUST_TARGET="$(rust_abi)"
			# RUST_TARGET is only honored if cross_compiling, but non-native ABIs aren't cross as
			# far as C parts and configure auto-detection are concerned as CHOST equals CBUILD
			cross_compiling=yes
		)
	fi

	ECONF_SOURCE=${S} \
	gnome2_src_configure "${myconf[@]}"

	if multilib_is_native_abi; then
		ln -s "${S}"/doc/html doc/html || die
	fi
}

multilib_src_compile() {
	# causes segfault if set, see bug #411765
	unset __GL_NO_DSO_FINALIZER
	gnome2_src_compile
}

multilib_src_install() {
	gnome2_src_install
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	multilib_foreach_abi gnome2_pkg_postinst
}

pkg_postrm() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	multilib_foreach_abi gnome2_pkg_postrm
}

