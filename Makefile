.PHONY: all statusbar-all statusbar-single install

all: statusbar-all statusbar-single

install:
	eval $$(go env) && go build -o $$GOPATH/bin/statusbar-all statusbar/cmds/all
	eval $$(go env) && go build -o $$GOPATH/bin/statusbar-single statusbar/cmds/single

statusbar-all:
	go build -o statusbar-all statusbar/cmds/all

statusbar-single:
	go build -o statusbar-single statusbar/cmds/single
