# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

DESCRIPTION="In-memory cache Erlang / Elixir library"
HOMEPAGE="https://github.com/processone/cache_tab"
SRC_URI="https://github.com/processone/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-erlang/p1_utils-1.0.1
	>=dev-lang/erlang-17.1"
RDEPEND="${DEPEND}"
