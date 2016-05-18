# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

DESCRIPTION="Small Erlang app that provides fast event stream processing"
HOMEPAGE="https://github.com/DeadZen/goldrush"
SRC_URI="https://github.com/DeadZen/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-lang/erlang-17.1"
RDEPEND="${DEPEND}"

DOCS=( README.org )

src_prepare() {
	# 'priv' directory contains only edoc.css, but doc isn't going to be built.
	rm -r "${S}/priv"
}
