# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

MY_PN="erlang_protobuffs"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Google's Protocol Buffers for Erlang"
HOMEPAGE="https://github.com/basho/erlang_protobuffs"
SRC_URI="https://github.com/basho/${MY_PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-lang/erlang-17.1"
RDEPEND="${DEPEND}"

DOCS=( AUTHORS  ChangeLog  README.markdown )

S="${WORKDIR}/${MY_P}"
