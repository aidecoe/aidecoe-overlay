# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Network backup and restore program"
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
	sys-libs/zlib
	acl? ( sys-apps/acl )
	afs? ( net-fs/openafs )
	nls? ( sys-devel/gettext )
	ssl? ( dev-libs/openssl )
	tcpd? ( sys-apps/tcp-wrappers )
	xattr? ( sys-apps/attr )
	"
RDEPEND="${DEPEND}"

src_unpack() {
	default
	mv burp "${P}" || die
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
