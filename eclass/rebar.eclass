# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: rebar.eclass
# @MAINTAINER:
# Amadeusz Żołnowski <aidecoe@gentoo.org>
# @AUTHOR:
# Amadeusz Żołnowski <aidecoe@gentoo.org>
# @BLURB: Build Erlang/OTP projects using dev-util/rebar.
# @DESCRIPTION:
# An eclass providing functions to build Erlang/OTP projects using
# dev-util/rebar.
#
# rebar is a tool which tries to resolve dependencies itself which is by
# cloning remote git repositories. Dependant projects are usually expected to
# be in sub-directory 'deps' rather than looking at system Erlang lib
# directory. Projects relying on rebar usually don't have 'install' make
# targets. The eclass workarounds some of these problems. It handles
# installation in a generic way for Erlang/OTP structured projects.

case "${EAPI:-0}" in
	0|1|2|3|4)
		die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}"
		;;
	5|6)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

[[ ${EAPI} = 5 ]] && inherit eutils

EXPORT_FUNCTIONS src_prepare src_compile src_install

RDEPEND="dev-lang/erlang"
DEPEND="${RDEPEND}
	dev-util/rebar"

# @FUNCTION: get_erl_libs
# @RETURN: the path to Erlang lib directory
# @DESCRIPTION:
get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

export ERL_LIBS="${EPREFIX}$(get_erl_libs)"

# @FUNCTION: _find_dep_version
# @INTERNAL
# @USAGE: <project_name>
# @RETURN: full path with EPREFIX to a Erlang package/project
# @DESCRIPTION:
# Find a Erlang package/project by name in Erlang lib directory. Project
# directory is usually suffixed with version. First match to <project_name> or
# <project_name>-* is returned.
_find_dep_version() {
	local pn="$1"
	local p

	pushd "${EPREFIX}$(get_erl_libs)" >/dev/null
	for p in ${pn} ${pn}-*; do
		if [[ -d ${p} ]]; then
			echo "${p#${pn}-}"
			return 0
		fi
	done
	popd >/dev/null

	return 1
}

# @FUNCTION: eawk
# @USAGE: <file> <args>
# @DESCRIPTION:
# Edit file <file> in place with awk. Pass all arguments following <file> to
# awk.
eawk() {
	local f="$1"; shift
	local tmpf="$(emktemp)"

	cat "${f}" >"${tmpf}" || return 1
	awk "$@" "${tmpf}" >"${f}"
}

# @FUNCTION: erebar
# @USAGE: <target>
# @DESCRIPTION:
# Run rebar with verbose flag. Die on failure.
erebar() {
	debug-print-function ${FUNCNAME} "${@}"

	rebar -v skip_deps=true "$1" || die "rebar $1 failed"
}

# @FUNCTION: rebar_fix_include_path
# @USAGE: <project_name> [<rebar_config>]
# @DESCRIPTION:
# Fix path in rebar.config to 'include' directory of dependant project/package,
# so it points to installation in system Erlang lib rather than relative 'deps'
# directory.
#
# <rebar_config> is optional. Default is 'rebar.config'.
#
# The function dies on failure.
rebar_fix_include_path() {
	debug-print-function ${FUNCNAME} "${@}"

	local pn="$1"
	local rebar_config="${2:-rebar.config}"
	local erl_libs="${EPREFIX}$(get_erl_libs)"
	local pv="$(_find_dep_version "${pn}")"

	eawk "${rebar_config}" \
		-v erl_libs="${erl_libs}" -v pn="${pn}" -v pv="${pv}" \
		'/^{[[:space:]]*erl_opts[[:space:]]*,/, /}[[:space:]]*\.$/ {
	pattern = "\"(./)?deps/" pn "/include\"";
	if (match($0, "{i,[[:space:]]*" pattern "[[:space:]]*}")) {
		sub(pattern, "\"" erl_libs "/" pn "-" pv "/include\"");
	}
	print $0;
	next;
}
1
' || die "failed to fix include paths in ${rebar_config}"
}

# @FUNCTION: rebar_remove_deps
# @USAGE: [<rebar_config>]
# @DESCRIPTION:
# Remove dependencies list from rebar.config and deceive build rules that any
# dependencies are already fetched and built. Otherwise rebar tries to fetch
# dependencies and compile them.
#
# <rebar_config> is optional. Default is 'rebar.config'.
#
# The function dies on failure.
rebar_remove_deps() {
	debug-print-function ${FUNCNAME} "${@}"

	local rebar_config="${1:-rebar.config}"

	mkdir -p "${S}/deps" && :>"${S}/deps/.got" && :>"${S}/deps/.built" || die
	eawk "${rebar_config}" \
		'/^{[[:space:]]*deps[[:space:]]*,/, /}[[:space:]]*\.$/ {
	if ($0 ~ /}[[:space:]]*\.$/) {
		print "{deps, []}.";
	}
	next;
}
1
' || die "failed to remove deps from ${rebar_config}"
}

# @FUNCTION: rebar_set_vsn
# @USAGE: [<version>]
# @DESCRIPTION:
# Set version in project description file if it's not set.
#
# <version> is optional. Default is PV stripped from version suffix.
#
# The function dies on failure.
rebar_set_vsn() {
	debug-print-function ${FUNCNAME} "${@}"

	local version="${1:-${PV%_*}}"

	sed -e "s/vsn, git/vsn, \"${version}\"/" \
		-i "${S}/src/${PN}.app.src" \
		|| die "failed to set version in src/${PN}.app.src"
}

# @FUNCTION: rebar_src_prepare
# @DESCRIPTION:
# Prevent rebar from fetching in compiling dependencies. Set version in project
# description file if it's not set.
#
# Existence of rebar.config is optional, but file description file must exist
# at 'src/${PN}.app.src'.
rebar_src_prepare() {
	debug-print-function ${FUNCNAME} "${@}"

	rebar_set_vsn
	[[ -f rebar.config ]] && rebar_remove_deps
}

# @FUNCTION: rebar_src_compile
# @DESCRIPTION:
# Compile project with rebar.
rebar_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	erebar compile
}

# @FUNCTION: rebar_src_install
# @DESCRIPTION:
# Install BEAM files, include headers, executables and native libraries.
# Install standard docs like README or defined in DOCS variable. Optionally
#
# Function expects that project conforms to Erlang/OTP structure.
rebar_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	local bin
	local dest="$(get_erl_libs)/${P}"

	insinto "${dest}"
	doins -r ebin
	[[ -d include ]] && doins -r include
	[[ -d bin ]] && for bin in bin/*; do dobin "$bin"; done
	[[ -d priv ]] && cp -pR priv "${ED}${dest}/"

	einstalldocs
}
