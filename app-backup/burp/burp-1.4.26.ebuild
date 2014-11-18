# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils user

DESCRIPTION="Network backup and restore client and server for Unix and Windows"
HOMEPAGE="http://burp.grke.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="acl afs ipv6 nls ssl tcpd xattr"

DEPEND="
	dev-libs/uthash
	sys-libs/libcap
	net-libs/librsync
	sys-libs/ncurses
	sys-libs/zlib
	acl? ( sys-apps/acl )
	afs? ( net-fs/openafs )
	nls? ( sys-devel/gettext )
	ssl? ( dev-libs/openssl )
	tcpd? ( sys-apps/tcp-wrappers )
	xattr? ( sys-apps/attr )
	"
RDEPEND="${DEPEND}
	virtual/logger
	"

DOCS=( CONTRIBUTORS DONATIONS UPGRADING )
PATCHES=( ${FILESDIR}/${PV}-tinfo.patch )

pkg_setup() {
	enewgroup "${PN}"
	enewuser "${PN}" -1 "" "" "${PN}"
}

src_unpack() {
	default
	mv burp "${P}" || die
}

src_prepare() {
	epatch "${PATCHES[@]}"
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--sbindir=/usr/sbin
		--sysconfdir=/etc/burp
		--enable-largefile
		$(use_with ssl openssl)
		$(use_enable acl)
		$(use_enable afs)
		$(use_enable ipv6)
		$(use_enable nls)
		$(use_enable xattr)
		$(use_with tcpd tcp-wrappers)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	fowners root:burp /etc/burp /var/spool/burp
	fperms 775 /etc/burp /var/spool/burp

	if use ssl; then
		# The server will create this directory if it doesn't exist, but the
		# client won't.  It must be writable by both.
		dodir /etc/burp/CA
		fowners root:burp /etc/burp/CA
		fperms 775 /etc/burp/CA
	fi

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	dodoc docs/*

	sed -e 's|^# user=graham|user = burp|' \
		-e 's|^# group=nogroup|group = burp|' \
		-e 's|^pidfile = .*|lockfile = /run/lock/burp/server.lock|' \
		-i "${D}"/etc/burp/burp-server.conf || die
}

pkg_postinst() {
	if use ssl; then
		einfo "Generating initial CA certificates and keys if necessary..."
		# Set $HOME to a directory writable by the server process.  OpenSSL
		# writes its "random state" file there while generating the certs/keys.
		if [ -d /run/lock/burp ]; then
			mkdir -m 0775 /run/lock/burp \
				|| ewarn 'Failed to create /run/lock/burp directory'
		fi
		chown burp:burp /run/lock/burp \
			|| ewarn 'Failed to change owner of /run/lock/burp direcoty'
		HOME=/var/spool/burp \
			/usr/sbin/burp -c /etc/burp/burp-server.conf -F -g \
			|| ewarn 'Failed to generate certificates for burp'
	fi
}
