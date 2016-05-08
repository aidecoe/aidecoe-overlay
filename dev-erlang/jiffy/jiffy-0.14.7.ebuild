# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

DESCRIPTION="JSON NIFs for Erlang"
HOMEPAGE="https://github.com/davisp/jiffy"
SRC_URI="https://github.com/davisp/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-lang/erlang-17.1"
RDEPEND="${DEPEND}"
