# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=qubes-core-vchan-xen
MY_P=${MY_PN}-${PV}

DESCRIPTION="The Qubes core libraries for installation inside a Qubes Dom0 and VM"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}"

DEPEND=">=app-emulation/xen-tools-4.8"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default

	sed -e "s@/usr/lib/@/usr/$(get_libdir)/@" -i "${S}"/Makefile || die
}

src_compile() {
	emake all
}
