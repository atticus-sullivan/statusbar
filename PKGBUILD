# Maintainer: Lukas Heindl <oss.heindl@protonmail.com>
pkgname=vanela-panel
pkgver=1.0.1
pkgrel=1
pkgdesc="A simple modular statusbar for bspwm"
arch=('x86_64')
url="https://github.com/atticus-sullivan/statusbar"
license=('MIT')
makedepends=('git' 'go')
depends=('bash' 'xdo' 'bspwm' 'xtitle' 'flameshot')
optdepends=('dmenu: can also be installed manually', 'lemonbar: maybe you built your own one')
source=("statusbar-${pkgver}.tar.gz::${url}/archive/refs/tags/${pkgver}.tar.gz")
sha256sums=('SKIP')

prepare() {
	cd "statusbar-${pkgver}"
	mkdir -p build/
	export GOPATH="${srcdir}"
	go mod download -modcacherw
}

build() {
	cd "statusbar-$pkgver"

	export CGO_CPPFLAGS="${CPPFLAGS}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	export GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external -mod=readonly -modcacherw"

	# Build the Go binaries
	go build -v -o "build" statusbar/cmds/...
}

package() {
	cd "statusbar-$pkgver"
	install -Dm755 build/all    "$pkgdir"/usr/local/bin/statusbar-all
	install -Dm755 build/single "$pkgdir"/usr/local/bin/statusbar-single
	install -Dm755 "cal.bash"          "$pkgdir/usr/local/bin/vanela-cal"
	install -Dm755 "vanela-panel.bash" "$pkgdir/usr/local/bin/vanela-panel"
}
