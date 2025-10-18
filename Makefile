.PHONY: all statusbar-all statusbar-single install clean pkg

all: statusbar-all statusbar-single

install: pkg
	makepkg -i

pkg:
	makepkg -c

statusbar-all:
	go build -o statusbar-all statusbar/cmds/all

statusbar-single:
	go build -o statusbar-single statusbar/cmds/single

clean:
	-$(RM) *.tar.gz
	-paccache -r -c . -k 1
