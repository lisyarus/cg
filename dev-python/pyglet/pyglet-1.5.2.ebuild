# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..10} )

inherit distutils-r1 virtualx

DESCRIPTION="Cross-platform windowing and multimedia library for Python"
HOMEPAGE="http://www.pyglet.org/"
SRC_URI="https://github.com/pyglet/pyglet/archive/v${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux"
IUSE="alsa examples gtk +openal"

RDEPEND="
	virtual/opengl
	alsa? ( media-libs/alsa-lib[alisp] )
	gtk? ( x11-libs/gtk+:2 )
	openal? ( media-libs/openal )"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
#	ffmpeg? ( media-libs/avbin-bin )

# pyglet.gl.glx_info.GLXInfoException: pyglet requires an X server with GLX
RESTRICT=test

python_test() {
	python_is_python3 && return
	VIRTUALX_COMMAND="${PYTHON}"
	virtualmake tests/test.py
}

python_install_all() {
	DOCS=( NOTICE )
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi

	distutils-r1_python_install_all
}
