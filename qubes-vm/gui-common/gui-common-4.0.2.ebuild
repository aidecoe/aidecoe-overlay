# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=qubes-gui-common
MY_P=${MY_PN}-${PV}

DESCRIPTION="Common files for Qubes GUI - protocol headers"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_install() {
	doheader include/qubes-gui-protocol.h
	doheader include/qubes-xorg-tray-defs.h
}
