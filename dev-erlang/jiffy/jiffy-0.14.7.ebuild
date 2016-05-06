# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="JSON NIFs for Erlang"
HOMEPAGE="https://github.com/davisp/jiffy"
SRC_URI="https://github.com/davisp/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

CDEPEND=">=dev-lang/erlang-17.1"
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
		-i "${S}/src/jiffy.app.src" || die
}

src_compile() {
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v compile || die 'rebar compile failed'
}

src_install() {
	insinto "$(get_erl_libs)/${P}"
	doins -r ebin priv src
	dodoc "${DOCS[@]}"
}
