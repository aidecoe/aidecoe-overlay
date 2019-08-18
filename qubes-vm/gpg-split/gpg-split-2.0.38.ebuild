# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="qubes-app-linux-split-gpg"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="The Qubes service for secure GPG separation"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="app-text/pandoc"
DEPEND=">=app-crypt/gnupg-2"

S="${WORKDIR}/${MY_P}"

src_compile() {
	emake build
}

src_install() {
	emake DESTDIR="${D}" install-vm
}
