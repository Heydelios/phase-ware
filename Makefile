build: export/web_release.zip export/phaseware_windows.zip export/phaseware_linux.zip

export/web/index.html:
	mkdir -p export/web
	godot --headless --export-release "Web" $@
export/web_release.zip: export/web/index.html
	zip --junk-paths -r $@ export/web/*

export/windows/phaseware.exe:
	mkdir -p export/windows
	godot --headless --export-release "Windows Desktop" $@
export/phaseware_windows.zip: export/windows/phaseware.exe
	zip --junk-paths -r $@ export/windows/*

export/linux/phaseware:
	mkdir -p export/linux
	godot --headless --export-release "Linux" $@
export/phaseware_linux.zip: export/linux/phaseware
	zip --junk-paths -r $@ export/linux/*


clean:
	rm -rf export/*


trim-whitespace:
	find -name '*.gd' | xargs sed -Ei 's/[ 	]+$$//'

.PHONY: clean build build-windows build-linux trim-whitespace downscale-textures
