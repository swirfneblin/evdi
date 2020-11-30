#
# Copyright (c) 2015 - 2020 DisplayLink (UK) Ltd.
#

FLAGS=-Werror -Wextra -Wall -Wmissing-prototypes -Wstrict-prototypes -Wno-error=missing-field-initializers

EL8 := $(shell cat /etc/redhat-release | grep -c " 8." )
ifneq (,$(findstring 1, $(EL8)))
FLAGS:=$(FLAGS) -D EL8
endif

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all:
	CFLAGS="$(FLAGS)" $(MAKE) -C module $(MFLAGS)
	CFLAGS="-I../module $(FLAGS) $(CFLAGS)" $(MAKE) -C library $(MFLAGS)

install:
	$(MAKE) -C module install
	$(MAKE) -C library install

uninstall:
	$(MAKE) -C module uninstall
	$(MAKE) -C library uninstall

clean:
	$(MAKE) clean -C module $(MFLAGS)
	$(MAKE) clean -C library $(MFLAGS)

rebuild: ## Rebuild evdi after installs new kernel version (https://github.com/DisplayLink/evdi/issues/172)
	# patch -Np1 evdi-all-in-one-fixes.patch
	make PREFIX=/usr RUN_DEPMOD=1 install
	systemctl restart displaylink-driver.service
	systemctl restart dkms.service