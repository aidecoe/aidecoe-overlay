# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

MY_PN="erlang-sqlite3"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="SQLite gen_server port for Erlang"
HOMEPAGE="https://github.com/processone/erlang-sqlite3"
SRC_URI="https://github.com/processone/${MY_PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="ErlPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND=">=dev-lang/erlang-17.1"
DEPEND="${CDEPEND}
	dev-util/rebar"
RDEPEND="${CDEPEND}"

RESTRICT=strip

S="${WORKDIR}/${MY_P}"

get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

src_prepare() {
	# Suppress deps check.
	cat<<EOF >>"${S}/rebar.config.script"
lists:keystore(deps, 1, CONFIG, {deps, []}).
EOF
	sed -e "s/vsn, git/vsn, \"${PV%_*}\"/" \
		-i "${S}/src/${PN}.app.src" || die
}

src_compile() {
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v compile || die 'rebar compile failed'
}

src_install() {
	insinto "$(get_erl_libs)/${P}"
	doins -r ebin include priv src
}
