# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit xorg-2

MY_PN="qubes-gui-agent-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes input driver and window buffers handling"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

KEYWORDS="~amd64"
IUSE=""

RDEPEND="x11-base/xorg-server"
DEPEND="${RDEPEND}
	qubes-vm/libvchan-xen:=
	qubes-vm/gui-common
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}/${PN}"

src_configure() {
	./autogen.sh || die
	emake distclean
	xorg-2_src_configure
}
