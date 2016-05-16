# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

DESCRIPTION="TLS / SSL native driver for Erlang / Elixir"
HOMEPAGE="https://github.com/processone/fast_tls"
SRC_URI="https://github.com/processone/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-erlang/p1_utils-1.0.3
	>=dev-lang/erlang-17.1
	dev-libs/openssl:0"
RDEPEND="${DEPEND}"
