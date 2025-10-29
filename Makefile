.PHONY: all statusbar-all statusbar-single install clean pkg pkg-dev pkg-release install-dev install-release

all: statusbar-all statusbar-single

statusbar-all:
	go build -o statusbar-all statusbar/cmds/all

statusbar-single:
	go build -o statusbar-single statusbar/cmds/single

install: install-dev

install-dev: clean pkg-dev # clean required because otherwise no way of finding the correct file based on the version based on the commit hash
	f="$$(find . -iname "vanela-panel-[a-f0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | head -n 1)" && sudo pacman -U "$$f"

install-release: pkg-release
	f="$$(find . -iname "vanela-panel-dev-[0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | head -n 1)" && sudo pacman -U "$$f"

pkg: pkg-dev

pkg-release:
	makepkg -D pkg-release -c
	mv pkg-release/*.tar.zst .

pkg-dev:
	makepkg -D pkg-dev -c
	mv pkg-dev/*.tar.zst .

clean:
	-$(RM) *.tar.gz *.tar.zst
