# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

GH_RN='github:Robpol86'
GH_REF="v${PV}"

inherit git-hosting
inherit distutils-r1

DESCRIPTION='Generate simple tables in terminals from a nested list of strings'
LICENSE='MIT'

SLOT='0'

KEYWORDS='~amd64 ~arm ~arm64'
