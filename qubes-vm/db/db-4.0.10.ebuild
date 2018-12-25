# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python{2_7,3_5,3_6} )

inherit distutils-r1 systemd

MY_PN=qubes-core-qubesdb
MY_P=${MY_PN}-${PV}

DESCRIPTION="QubesDB libs and daemon service"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

S="${WORKDIR}/${MY_P}"

DEPEND="sys-apps/systemd
	qubes-vm/libvchan-xen:=
	python? ( ${PYTHON_DEPS} )"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

SYSTEMD_UNITS=(
	daemon/qubes-db.service
)

install_systemd_units() {
	local unit
	for unit in "${@}"; do
		systemd_dounit "${unit}"
	done

}

bindings() {
	local ret=0

	if use "$1"; then
		pushd "$1" || die
		shift
		"$@"
		ret=$?
		popd || die
	fi

	return $ret
}

src_prepare() {
	default
	bindings python distutils-r1_src_prepare
}

src_compile() {
	BACKEND_VMM=xen emake -C daemon
	BACKEND_VMM=xen emake -C client

	BACKEND_VMM=xen bindings python distutils-r1_src_compile
}

src_install() {
	default
	install_systemd_units "${SYSTEMD_UNITS[@]}"

	bindings python distutils-r1_src_install
}
