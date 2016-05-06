# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="Erlang Utility Modules from ProcessOne"
HOMEPAGE="https://github.com/processone/p1_utils"
SRC_URI="https://github.com/processone/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

CDEPEND=">=dev-lang/erlang-17.1"
DEPEND="${CDEPEND}
	dev-util/rebar"
RDEPEND="${CDEPEND}"

RESTRICT=strip

DOCS=( CHANGELOG.md README.md )

get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

src_compile() {
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v compile || die 'rebar compile failed'
	if use doc; then
		rebar -v doc || die 'rebar doc failed'
	fi
}

src_install() {
	insinto "$(get_erl_libs)/${P}"
	doins -r ebin src
	dodoc "${DOCS[@]}"
	use doc && dohtml -r doc/*
}
