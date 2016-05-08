# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

DESCRIPTION="A logging framework for Erlang/OTP"
HOMEPAGE="https://github.com/basho/lager"
SRC_URI="https://github.com/basho/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-erlang/goldrush-0.1.7
	>=dev-lang/erlang-17.1"
RDEPEND="${DEPEND}"
