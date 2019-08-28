# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd tmpfiles user

MY_PN="qubes-core-agent-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes VM qrexec"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}/qrexec"

CDEPEND="qubes-vm/libvchan-xen:=
	qubes-vm/libqrexec"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	acct-group/qubes"

PATCHES=( ${FILESDIR}/0001-Don-t-include-postlogin-in-pam-file.patch )

SYSTEMD_UNITS=(
	../vm-systemd/qubes-qrexec-agent.service
)

install_systemd_units() {
	local unit
	for unit in "${@}"; do
		systemd_dounit "${unit}"
	done
}

src_compile() {
	BACKEND_VMM=xen default
}

src_install() {
	default
	dotmpfiles "${FILESDIR}"/qubes-vm-qrexec.conf
	install_systemd_units "${SYSTEMD_UNITS[@]}"
	doinitd ../vm-init.d/qubes-qrexec-agent
}

pkg_postinst() {
	tmpfiles_process qubes-vm-qrexec.conf
}
