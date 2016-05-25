# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit rebar

DESCRIPTION="Fast Expat based Erlang XML parsing library"
HOMEPAGE="https://github.com/processone/fast_xml"
SRC_URI="https://github.com/processone/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND=">=dev-erlang/p1_utils-1.0.0
	>=dev-lang/erlang-17.1
	dev-libs/expat
	test? ( dev-lang/elixir )"
RDEPEND="${DEPEND}"

DOCS=( CHANGELOG.md  README.md )
