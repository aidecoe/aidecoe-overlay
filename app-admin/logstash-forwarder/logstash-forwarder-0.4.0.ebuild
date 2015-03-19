# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit user

DESCRIPTION="Collects logs locally in preparation for processing elsewhere"
HOMEPAGE="https://github.com/elastic/logstash-forwarder"
SRC_URI="https://github.com/elastic/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/go"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup logstash
	enewuser logstash -1 -1 -1 logstash
}

src_install() {
	dobin "${PN}"
	dodoc "${PN}".conf.example CHANGELOG README.md
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
}
