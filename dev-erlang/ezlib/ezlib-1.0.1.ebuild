# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

DESCRIPTION="Native zlib driver for Erlang and Elixir"
HOMEPAGE="https://github.com/processone/ezlib"
SRC_URI="https://github.com/processone/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-lang/erlang-17.1
	sys-libs/zlib"
RDEPEND="${DEPEND}"

DOCS=( CHANGELOG.md  README.md )
