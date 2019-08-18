# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

MY_PN="qubes-linux-utils"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes memory information reporter"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}/qmemman"

CDEPEND="qubes-vm/libvchan-xen:="
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

SYSTEMD_UNITS=(
	qubes-meminfo-writer.service
	qubes-meminfo-writer-dom0.service
)

install_systemd_units() {
	local unit
	for unit in "${@}"; do
		systemd_dounit "${unit}"
	done

}

src_install() {
	dosbin meminfo-writer
	install_systemd_units "${SYSTEMD_UNITS[@]}"
	newinitd "${FILESDIR}"/qubes-meminfo-writer.initd qubes-meminfo-writer
}
