# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
CMAKE_ECLASS=cmake

inherit cmake-multilib python-any-r1 toolchain-funcs

DESCRIPTION="Nonlinear least-squares minimizer"
HOMEPAGE="http://ceres-solver.org/"
#SRC_URI="http://ceres-solver.org/${P}.tar.gz"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz"

LICENSE="sparse? ( BSD ) !sparse? ( LGPL-2.1 ) cxsparse? ( BSD )"
SLOT="0/1"
KEYWORDS="amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="cxsparse cuda doc examples gflags lapack +schur sparse test"
RESTRICT="
	mirror
	!test? ( test )
"

REQUIRED_USE="test? ( gflags ) sparse? ( lapack ) abi_x86_32? ( !sparse !lapack )"

BDEPEND="${PYTHON_DEPS}
	>=dev-cpp/eigen-3.3:=
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	doc? (
		dev-python/sphinx
		dev-python/sphinx_rtd_theme
	)
	lapack? ( virtual/pkgconfig )
"
RDEPEND="
	dev-cpp/glog[gflags?,${MULTILIB_USEDEP}]
	cxsparse? ( sci-libs/cxsparse:0= )
	lapack? ( virtual/lapack )
	sparse? (
		sci-libs/amd:0=
		sci-libs/camd:0=
		sci-libs/ccolamd:0=
		sci-libs/cholmod:0=[metis(+)]
		sci-libs/colamd:0=
		sci-libs/spqr:0=
	)"

DEPEND="${RDEPEND}"

DOCS=( README.md CONTRIBUTING.md )

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	# search paths work for prefix
	sed -e "s:/usr:${EPREFIX}/usr:g" \
		-i cmake/*.cmake || die

	# remove Werror
	sed -e 's/-Werror=(all|extra)//g' \
		-i CMakeLists.txt || die

	# respect gentoo doc install directory
	sed -e "s:share/doc/ceres:share/doc/${PF}:" \
		-i docs/source/CMakeLists.txt || die
}

src_configure() {
	# CUSTOM_BLAS=OFF EIGENSPARSE=OFF MINIGLOG=OFF CXX11=OFF
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DBUILD_BENCHMARKS=OFF
		-DBUILD_EXAMPLES=OFF
		-DBUILD_TESTING="$(usex test)"
		-DBUILD_DOCUMENTATION="$(usex doc)"
		-DBUILD_SHARED_LIBS=ON
		-DCUDA=$(usex cuda)
		-DGFLAGS="$(usex gflags)"
		-DLAPACK="$(usex lapack)"
		-DSCHUR_SPECIALIZATIONS="$(usex schur)"
		-DCXSPARSE="$(usex cxsparse)"
		-DSUITESPARSE="$(usex sparse)"
	)
	use sparse || use cxsparse || mycmakeargs+=( -DEIGENSPARSE=ON )
	cmake-multilib_src_configure
}

src_install() {
	cmake-multilib_src_install

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
		dodoc -r examples data
	fi
}
