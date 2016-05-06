# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="Fast Expat based Erlang XML parsing library"
HOMEPAGE="https://github.com/processone/fast_xml"
SRC_URI="https://github.com/processone/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND=">=dev-erlang/p1_utils-1.0.0
	>=dev-lang/erlang-17.1
	dev-libs/expat"
DEPEND="${CDEPEND}
	dev-util/rebar"
RDEPEND="${CDEPEND}"

RESTRICT=strip

DOCS=( CHANGELOG.md README.md )

get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

src_prepare() {
	# Suppress deps check.
	cat<<EOF >>"${S}/rebar.config.script"
lists:keystore(deps, 1, CONFIG, {deps, []}).
EOF
}

src_compile() {
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v compile || die 'rebar compile failed'
}

src_install() {
	insinto "$(get_erl_libs)/${P}"
	doins -r ebin include priv src
	dodoc "${DOCS[@]}"
}
