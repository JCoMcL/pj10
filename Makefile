export/web_realease.zip: export/web/index.html
	zip --junk-paths -r $@ export/web/*
