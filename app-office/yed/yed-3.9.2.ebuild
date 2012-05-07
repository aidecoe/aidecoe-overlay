# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils java-pkg-2

MY_PN="yEd"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Effective high-quality diagrams editor"
HOMEPAGE="http://www.yworks.com/en/products_yed_about.html"
SRC_URI="${MY_P}.zip"
DOWNLOAD_URL="http://www.yworks.com/en/products_download.php?file=${SRC_URI}"

LICENSE="yEd-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jre-1.6"

RESTRICT="fetch"

pkg_nofetch() {
	eerror "${SRC_URI} not found!"
	echo
	elog "Please download the ${SRC_URI} from"
	elog "  ${DOWNLOAD_URL}"
	elog "and place it in ${DISTDIR}."
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	java-pkg_dolauncher "${PN}"
	make_desktop_entry "${PN}" "yEd Graph Editor"
}
