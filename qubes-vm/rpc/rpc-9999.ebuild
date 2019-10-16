# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

MY_PN="qubes-core-agent-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes VM RPC"
HOMEPAGE="https://www.qubes-os.org/"
EGIT_REPO_URI="https://github.com/aidecoe/${MY_PN}.git"
EGIT_BRANCH="makefiles-split-qubes-rpc"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE="kde nautilus thunar"

S="${WORKDIR}/${P}/qubes-rpc"

CDEPEND="qubes-vm/libqrexec"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"


src_compile() {
	emake DEBUG=0
}

src_install() {
	default

	for flag in kde nautilus thunar; do
		use "${flag}" &&  emake -C "${flag}" DESTDIR="${D}" install
	done
}
