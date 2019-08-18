# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="qubes-linux-utils"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes VM udev rules and scripts"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}/udev"

DEPEND=""
RDEPEND="sys-fs/lvm2
	qubes-vm/db
	virtual/libiconv
	virtual/udev"

src_install() {
	SCRIPTSDIR=/usr/lib/qubes SYSLIBDIR=/lib default
}
