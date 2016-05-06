# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="Riak Protocol Buffers Messages"
HOMEPAGE="https://github.com/basho/riak_pb"
SRC_URI="https://github.com/basho/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

CDEPEND=">=dev-erlang/protobuffs-0.8.2
	>=dev-lang/erlang-17.1"
DEPEND="${CDEPEND}
	dev-util/rebar"
RDEPEND="${CDEPEND}"

RESTRICT=strip

DOCS=( README.md )

get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

src_prepare() {
	# Suppress deps check.
	cat<<EOF >>"${S}/rebar.config.script"
lists:keystore(deps, 1, CONFIG, {deps, []}).
EOF
	sed -e "s/vsn, git/vsn, \"${PV}\"/" \
		-i "${S}/src/${PN}.app.src" || die
}

src_compile() {
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v compile || die 'rebar compile failed'
}

src_install() {
	insinto "$(get_erl_libs)/${P}"
	doins -r ebin include src
}
