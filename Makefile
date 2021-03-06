INSTALL_DIRECTORY=/usr/local/bin
TEMPORARY_DIRECTORY?=/tmp/drag-build.dst
TEMPORARY_PACKAGE_DIRECTORY?=/tmp/drag-package.dst

XCODE_COMMAND=$(shell { command -v xctool || command -v xcodebuild; } 2>/dev/null)
XCODE_FLAGS=-project 'drag.xcodeproj' -scheme 'drag' -configuration 'Release' DSTROOT=$(TEMPORARY_DIRECTORY)

PACKAGE_NAME=drag.pkg
TEMPORARY_PACKAGE_NAME=$(TEMPORARY_PACKAGE_DIRECTORY)/temp.pkg
COMPONENTS_PLIST_NAME=$(TEMPORARY_PACKAGE_DIRECTORY)/Components.plist

VERSION=0.1

.PHONY: all clean install package uninstall

all:
	$(XCODE_COMMAND) $(XCODE_FLAGS) build

clean:
	rm -f "$(COMPONENTS_PLIST_NAME)"
	rm -f "$(PACKAGE_NAME)"
	rm -rf "$(TEMPORARY_DIRECTORY)"
	$(XCODE_COMMAND) $(XCODE_FLAGS) clean

install: package
	sudo installer -pkg drag.pkg -target /

package: clean
	$(XCODE_COMMAND) $(XCODE_FLAGS) install
	
	mkdir -p "$(TEMPORARY_PACKAGE_DIRECTORY)"
	
	pkgbuild \
		--analyze \
		--root "$(TEMPORARY_DIRECTORY)" \
		"$(COMPONENTS_PLIST_NAME)"
	
	pkgbuild \
		--component-plist "$(COMPONENTS_PLIST_NAME)" \
		--identifier "com.natestedman.drag" \
		--install-location "/" \
		--root "$(TEMPORARY_DIRECTORY)" \
		--version "$(VERSION)" \
		"$(TEMPORARY_PACKAGE_NAME)"
	
	productsign \
		--sign "Developer ID Installer" \
		"$(TEMPORARY_PACKAGE_NAME)" \
		"$(PACKAGE_NAME)"
	
	rm "$(TEMPORARY_PACKAGE_NAME)"
	rm "$(COMPONENTS_PLIST_NAME)"

uninstall:
	rm -f "$(INSTALL_DIRECTORY)/drag"
