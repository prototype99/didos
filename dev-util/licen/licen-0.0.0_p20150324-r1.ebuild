# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

PYTHON_COMPAT=( py{py3,thon{2_7,3_{5,6,7}}} )

## distutils-r1.eclass:
DISTUTILS_SINGLE_IMPL=true

## git-hosting.eclas:
GH_RN='github:lord63'
GH_REF="5969f6b11aa36e7f8da49b5cf81ef8d51415290f"

inherit git-hosting
inherit distutils-r1

DESCRIPTION='Licence file generator. Yet another lice, but implemented with Jinja2 and docopt'
LICENSE='MIT'

SLOT='0'
KEYWORDS='~amd64 ~arm ~arm64'

RDEPEND="
	dev-python/docopt:0[${PYTHON_USEDEP}]
	dev-python/jinja:0[${PYTHON_USEDEP}]
"
