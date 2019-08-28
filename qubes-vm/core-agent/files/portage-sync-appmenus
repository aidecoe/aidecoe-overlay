#!/bin/bash

if [[ "${EBUILD_PHASE}" == "postinst" ]] || [[ "${EBUILD_PHASE}" == "postrm" ]]; then
	/usr/lib/qubes/qubes-trigger-sync-appmenus.sh
fi
