all: site css
css:
	cp base.css html/
site:
	ruby Site.rb
images: site
	mkdir html/images
	cp extras/images/* html/images/
doc:
	cp -R extras/doc/PageTemplate html/doc
clean:
	rm -rf html

test-install:
	sudo cp -Rf html/* /var/www/html
