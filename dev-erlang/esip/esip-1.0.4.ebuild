# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="ProcessOne SIP server component"
HOMEPAGE="https://github.com/processone/esip"
SRC_URI="https://github.com/processone/${PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND=">=dev-erlang/fast_tls-1.0.0
	>=dev-erlang/stun-1.0.0
	>=dev-erlang/p1_utils-1.0.2
	>=dev-lang/erlang-17.1"
DEPEND="${CDEPEND}
	dev-util/rebar"
RDEPEND="${CDEPEND}"

RESTRICT=strip

get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

find_dep() {
	local dep="$1"
	local d
	local erl_libs="${EPREFIX}$(get_erl_libs)"

	for d in ${erl_libs}/${dep} ${erl_libs}/${dep}-*; do
		if [[ -d ${d} ]]; then
			echo "${d}"
			return 0
		fi
	done

	return 1
}

src_prepare() {
	# Suppress deps check.
	sed \
		-e 's|"deps/stun/include"|"'$(find_dep stun)'/include"|' \
		-e '32,34d' \
		-e '31a{deps, []}.' \
		-i "${S}/rebar.config"
}

src_compile() {
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v compile || die 'rebar compile failed'
}

src_install() {
	insinto "$(get_erl_libs)/${P}"
	doins -r ebin include priv src
}
