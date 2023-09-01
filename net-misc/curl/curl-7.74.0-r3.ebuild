# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils prefix multilib-minimal

DESCRIPTION="A Client that groks URLs"
HOMEPAGE="https://curl.haxx.se/"
SRC_URI="https://curl.haxx.se/download/${P}.tar.xz"

LICENSE="curl"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="adns alt-svc brotli +ftp gnutls gopher hsts http2 idn +imap ipv6 kerberos ldap libressl mbedtls metalink nss +openssl +pop3 +progress-meter rtmp samba +smtp ssh ssl static-libs test telnet +tftp threads winssl zstd"
IUSE+=" curl_ssl_gnutls curl_ssl_libressl curl_ssl_mbedtls curl_ssl_nss +curl_ssl_openssl curl_ssl_winssl"
IUSE+=" nghttp3 quiche"
IUSE+=" elibc_Winnt"
IUSE+=" +cookies curldebug dict +digest +file fish ftps +http +https imaps +largefile ldaps libcurl-option libgcc manual ntlm-wb +openssl-auto-load-config pop3s proxy psl +rt rtsp sambas +shared-libs smtps ssh2 ssh-old symbol-hiding tls-srp +unix-sockets verbose versioned-symbols +zlib zsh"

#lead to lots of false negatives, bug #285669
RESTRICT="!test? ( test )"

CERTDEP="app-misc/ca-certificates"

RDEPEND="ldap? ( net-nds/openldap[${MULTILIB_USEDEP}] )
	brotli? ( app-arch/brotli:=[${MULTILIB_USEDEP}] )
	ssl? (
		gnutls? (
			net-libs/gnutls:0=[static-libs?,${MULTILIB_USEDEP}]
			dev-libs/nettle:0=[${MULTILIB_USEDEP}]
			${CERTDEP}
		)
		libressl? (
			dev-libs/libressl:0=[static-libs?,${MULTILIB_USEDEP}]
		)
		mbedtls? (
			net-libs/mbedtls:0=[${MULTILIB_USEDEP}]
			${CERTDEP}
		)
		openssl? (
			dev-libs/openssl:0=[static-libs?,${MULTILIB_USEDEP}]
		)
		nss? (
			dev-libs/nss:0[${MULTILIB_USEDEP}]
			${CERTDEP}
		)
	)
	http2? ( net-libs/nghttp2[${MULTILIB_USEDEP}] )
	nghttp3? (
		net-libs/nghttp3[${MULTILIB_USEDEP}]
		net-libs/ngtcp2[ssl,${MULTILIB_USEDEP}]
	)
	quiche? ( >=net-libs/quiche-0.3.0[${MULTILIB_USEDEP}] )
	idn? ( net-dns/libidn2:0=[static-libs?,${MULTILIB_USEDEP}] )
	adns? ( net-dns/c-ares:0[${MULTILIB_USEDEP}] )
	kerberos? ( >=virtual/krb5-0-r1[${MULTILIB_USEDEP}] )
	metalink? ( >=media-libs/libmetalink-0.1.1[${MULTILIB_USEDEP}] )
	rtmp? ( media-video/rtmpdump[${MULTILIB_USEDEP}] )
	ssh2? ( net-libs/libssh2[${MULTILIB_USEDEP}] )
	ssh-old? ( net-libs/libssh )
	zlib? ( sys-libs/zlib[${MULTILIB_USEDEP}] )
	zstd? ( app-arch/zstd:=[${MULTILIB_USEDEP}] )
	ldaps? ( net-nds/openldap[ssl] )
	psl? ( net-libs/libpsl )"
DEPEND="${RDEPEND}"
BDEPEND=">=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
	test? (
		sys-apps/diffutils
		dev-lang/perl
	)"

REQUIRED_USE="
	winssl? ( elibc_Winnt )
	?? ( threads adns )
	ssl? (
		^^ (
			gnutls
			libressl
			mbedtls
			nss
			openssl
			winssl
		)
	)
	curl_ssl_gnutls? ( gnutls )
	curl_ssl_libressl? ( libressl )
	curl_ssl_mbedtls? ( mbedtls )
	curl_ssl_openssl? ( openssl )
	curl_ssl_nss? ( nss )
	kerberos? ( digest )
	ntlm-wb?  ( digest ssl http )
	ssh? ( ?? ( ssh2 ssh-old ) )
	https? ( http ssl )
	ftps? ( ftp ssl )
	ldaps? ( ldap ssl )
	pop3s? ( pop3 ssl )
	imaps? ( imap ssl )
	openssl-auto-load-config? ( curl_ssl_openssl )
	samba? ( digest ^^ ( curl_ssl_openssl curl_ssl_gnutls curl_ssl_nss ) )
	sambas? ( samba ssl )
	smtps? ( smtp ssl )
	static-libs? ( symbol-hiding )
	versioned-symbols? ( shared-libs )"

DOCS=( CHANGES README docs/FEATURES.md docs/INTERNALS.md \
	docs/FAQ docs/BUGS.md docs/CONTRIBUTE.md )

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/curl/curlbuild.h
)

MULTILIB_CHOST_TOOLS=(
	/usr/bin/curl-config
)

src_prepare() {
	eapply "${FILESDIR}"/${PN}-7.30.0-prefix.patch
	eapply "${FILESDIR}"/${PN}-respect-cflags-3.patch
	eapply "${FILESDIR}"/${PN}-fix-gnutls-nettle.patch

	sed -i '/LD_LIBRARY_PATH=/d' configure.ac || die #382241
	sed -i '/CURL_MAC_CFLAGS/d' configure.ac || die #637252 note this is mac only

	eapply_user
	eprefixify curl-config.in
	eautoreconf
}

multilib_src_configure() {
	# We make use of the fact that later flags override earlier ones
	# So start with all ssl providers off until proven otherwise
	# TODO: in the future, we may want to add wolfssl (https://www.wolfssl.com/)
	use curl_ssl_gnutls && einfo "SSL provided by gnutls"
	use curl_ssl_libressl && einfo "SSL provided by LibreSSL"
	use curl_ssl_mbedtls && einfo "SSL provided by mbedtls"
	use curl_ssl_nss && einfo "SSL provided by nss"
	use curl_ssl_openssl && einfo "SSL provided by openssl"
	use curl_ssl_winssl && einfo "SSL provided by Windows"
	! use ssl && einfo "SSL disabled"
	local myconf=()
	if use curl_ssl_libressl || use curl_ssl_openssl; then
		myconf+=( --with-ssl --with-ca-path="${EPREFIX}"/etc/ssl/certs )
	else
		myconf+=( --without-ssl )
	fi

	ECONF_SOURCE="${S}" \
	myconf+=(
		--without-polarssl
		$(use_with gnutls gnutls)
		$(use_with gnutls nettle)
		$(use_with mbedtls mbedtls)
		$(use_with nss nss)
		$(use_with winssl winssl)
		$(use_enable alt-svc)
		$(use_enable digest crypto-auth)
		$(use_enable dict)
		--disable-ech
		--disable-esni
		$(use_enable file)
		$(use_enable ftp)
		$(use_enable gopher)
		$(use_enable hsts)
		$(use_enable http)
		$(use_enable imap)
		$(use_enable ldap)
		$(use_enable ldaps)
		--disable-mqtt
		$(use_enable ntlm-wb)
		$(use_enable pop3)
		$(use_enable rt)
		$(use_enable rtsp)
		$(use_enable samba smb)
		$(use_with ssh2 libssh2)
		$(use_with ssh-old libssh)
		$(use_enable smtp)
		$(use_enable telnet)
		$(use_enable tftp)
		$(use_enable tls-srp)
		$(use_enable adns ares)
		$(use_enable cookies)
		--enable-dateparse
		--enable-dnsshuffle
		--enable-doh
		--disable-get-easy-options
		--enable-hidden-symbols
		--enable-http-auth
		$(use_enable ipv6)
		$(use_enable largefile)
		$(use_enable manual)
		--enable-mime
		--enable-netrc
		$(use_enable progress-meter)
		$(use_enable proxy)
		--disable-sspi
		--disable-socketpair
		$(use_enable threads threaded-resolver)
		$(use_enable threads pthreads)
		$(use_enable versioned-symbols)
		--without-amissl
		--without-bearssl
		--without-cyassl
		--without-darwinssl
		$(use_with idn libidn2)
		$(use_with kerberos gssapi "${EPREFIX}"/usr)
		$(use_with metalink libmetalink)
		$(use_with http2 nghttp2)
		$(use_with psl libpsl)
		$(use_with nghttp3)
		$(use_with nghttp3 ngtcp2)
		$(use_with quiche)
		$(use_with rtmp librtmp)
		$(use_with brotli)
		--without-schannel
		--without-secure-transport
		--without-spnego
		--without-winidn
		--without-wolfssl
		$(use_with zlib)
		--disable-debug # just sets -g* flags
		--enable-warnings
		--disable-werror
		--disable-soname-bump
		$(use_enable curldebug)
		$(use_enable symbol-hiding)
		$(use_enable libcurl-option)
		$(use_enable libgcc)
		$(use_enable verbose)
		$(use_enable unix-sockets)
		$(use_enable openssl-auto-load-config)
		--without-mesalink #Rust written Baidu SSL lib
		--with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt
		# "Don't use the built-in CA store of the SSL library"
		--without-ca-fallback
	)

		if use curl_ssl_gnutls; then
			einfo "Default SSL provided by gnutls"
			myconf+=( --with-default-ssl-backend=gnutls )
		elif use curl_ssl_libressl; then
			einfo "Default SSL provided by LibreSSL"
			myconf+=( --with-default-ssl-backend=openssl )  # NOTE THE HACK HERE
		elif use curl_ssl_mbedtls; then
			einfo "Default SSL provided by mbedtls"
			myconf+=( --with-default-ssl-backend=mbedtls )
		elif use curl_ssl_nss; then
			einfo "Default SSL provided by nss"
			myconf+=( --with-default-ssl-backend=nss )
		elif use curl_ssl_openssl; then
			einfo "Default SSL provided by openssl"
			myconf+=( --with-default-ssl-backend=openssl )
		elif use curl_ssl_winssl; then
			einfo "Default SSL provided by Windows"
			myconf+=( --with-default-ssl-backend=winssl )
		else
			eerror "We can't be here because of REQUIRED_USE."
		fi

	use fish && myconf+=( --with-fish-functions-dir=yes ) || myconf+=( --without-fish-functions-dir )

	! use shared-libs && myconf+=( --disable-shared )

	! use static-libs && myconf+=( --disable-static )

	use zsh && myconf+=( --with-zsh-functions-dir="${EPREFIX}"/usr/share/zsh/site-functions )

	if use curl_ssl_openssl || use curl_ssl_gnutls ; then
		myconf+=( --with-ca-path="${EPREFIX}"/etc/ssl/certs )
	else
		myconf+=( --without-ca-path )
	fi

	econf "${myconf[@]}"

	if ! multilib_is_native_abi; then
		# avoid building the client
		sed -i -e '/SUBDIRS/s:src::' Makefile || die
		sed -i -e '/SUBDIRS/s:scripts::' Makefile || die
	fi

	# Fix up the pkg-config file to be more robust.
	# https://github.com/curl/curl/issues/864
	local priv=() libs=()
	if use zlib; then
		libs+=( "-lz" )
		priv+=( "zlib" )
	fi
	if use http2; then
		libs+=( "-lnghttp2" )
		priv+=( "libnghttp2" )
	fi
	if use quiche; then
		libs+=( "-lquiche" )
		priv+=( "quiche" )
	fi
	if use nghttp3; then
		libs+=( "-lnghttp3" "-lngtcp2" )
		priv+=( "libnghttp3" "-libtcp2" )
	fi
	if use curl_ssl_openssl; then
		libs+=( "-lssl" "-lcrypto" )
		priv+=( "openssl" )
	fi
	grep -q Requires.private libcurl.pc && die "need to update ebuild"
	libs=$(printf '|%s' "${libs[@]}")
	sed -i -r \
		-e "/^Libs.private/s:(${libs#|})( |$)::g" \
		libcurl.pc || die
	echo "Requires.private: ${priv[*]}" >> libcurl.pc
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete
	rm -rf "${ED}"/etc/
}
