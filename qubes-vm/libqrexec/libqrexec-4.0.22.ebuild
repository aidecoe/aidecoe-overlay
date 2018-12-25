# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="qubes-linux-utils"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes..."
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}/qrexec-lib"

CDEPEND=">=app-emulation/xen-tools-4.8
	qubes-vm/libvchan-xen:="
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

src_compile() {
	BACKEND_VMM=xen default
}

src_install() {
	INCLUDEDIR="/usr/include" LIBDIR="/usr/$(get_libdir)" default
}
