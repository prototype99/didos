# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5..10} )

inherit eutils elisp-common gnome2 python-single-r1 readme.gentoo-r1

DESCRIPTION="GTK+ Documentation Generator"
HOMEPAGE="https://www.gtk.org/${PN}/"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~s390 ~sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris"

IUSE="debug doc emacs glib-doc pdf test"
REQUIRED_USE="${PYTHON_REQUIRED_USE} test? ( pdf )"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-libs/glib-2.6:2
	dev-libs/libxslt
	>=dev-libs/libxml2-2.3.6:2
	~app-text/docbook-xml-dtd-4.3
	app-text/docbook-xsl-stylesheets
	~app-text/docbook-sgml-dtd-3.0
	>=app-text/docbook-dsssl-stylesheets-1.40
	emacs? ( >=app-editors/emacs-23.1:* )
	$(python_gen_cond_dep '
		dev-python/pygments[${PYTHON_MULTI_USEDEP}]
	')
	doc? ( app-text/yelp-tools )
	pdf? (
		|| (
			app-text/dblatex
			dev-java/fop
		)
	)
	test? ( dev-python/anytree )
"
DEPEND="${RDEPEND}
	~dev-util/${PN}-am-${PV}
	dev-util/itstool
	virtual/pkgconfig
"

pkg_setup() {
	DOC_CONTENTS="${PN} does no longer define global key bindings for Emacs.
		You may set your own key bindings for \"${PN}-insert\" and
		\"${PN}-insert-section\" in your ~/.emacs file."
	SITEFILE=61${PN}-gentoo.el
	python-single-r1_pkg_setup
}

src_prepare() {
	# Remove global Emacs keybindings, bug #184588
	eapply "${FILESDIR}"/${PN}-1.8-emacs-keybindings.patch
	# Fix dev-libs/glib[gtk-doc] doc generation tests by fixing stuff surrounding deprecations
	# https://gitlab.gnome.org/GNOME/glib/-/merge_requests/1488
	use glib-doc && eapply "${FILESDIR}"/${PN}-1.32-deprecation-parse-fixes.patch

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog \
		$(use_enable debug)
}

src_compile() {
	gnome2_src_compile
	use emacs && elisp-compile tools/${PN}.el
}

src_install() {
	gnome2_src_install

	python_fix_shebang "${ED}"/usr/bin/gtkdoc-depscan

	# Don't install this file, it's in ${PN}-am now
	rm "${ED}"/usr/share/aclocal/${PN}.m4 || die "failed to remove ${PN}.m4"

	if use doc; then
		docinto doc
		dodoc doc/*
		docinto examples
		dodoc examples/*
	fi

	if use emacs; then
		elisp-install ${PN} tools/${PN}.el*
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
		readme.gentoo_create_doc
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst
	if use emacs; then
		elisp-site-regen
		readme.gentoo_print_elog
	fi
}

pkg_postrm() {
	gnome2_pkg_postrm
	use emacs && elisp-site-regen
}
