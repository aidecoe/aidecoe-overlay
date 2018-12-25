# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit xorg-2

MY_PN="qubes-gui-agent-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="X.Org driver for dummy cards with Qubes patches"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

KEYWORDS="~amd64"
IUSE="dga"

RDEPEND=">=x11-base/xorg-server-1.0.99"
DEPEND="${RDEPEND}
	dga? ( x11-base/xorg-proto )"

S="${WORKDIR}/${MY_P}/xf86-video-dummy"

pkg_setup() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable dga)
	)
	xorg-2_pkg_setup
}

src_configure() {
	./autogen.sh || die
	emake distclean
	xorg-2_src_configure
}
