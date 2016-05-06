# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="Erlang port of Hamcrest"
HOMEPAGE="https://github.com/hyperthunk/hamcrest-erlang"
SRC_URI="https://dev.gentoo.org/~aidecoe/distfiles/${CATEGORY}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

CDEPEND=">=dev-lang/erlang-17.1"
DEPEND="${CDEPEND}
	dev-util/rebar"
RDEPEND="${CDEPEND}"

RESTRICT=strip

DOCS=( README.markdown )

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
