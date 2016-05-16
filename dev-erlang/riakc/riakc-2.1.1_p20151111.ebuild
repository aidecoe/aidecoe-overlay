# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rebar

DESCRIPTION="Erlang clients for Riak"
HOMEPAGE="https://github.com/basho/riak-erlang-client"
SRC_URI="https://dev.gentoo.org/~aidecoe/distfiles/${CATEGORY}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-erlang/riak_pb-2.1.0.7
	>=dev-lang/erlang-17.1"
RDEPEND="${DEPEND}"

DOCS=( README.md )
