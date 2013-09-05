build:
	jekyll build

deploy: build
	rsync -r _site/* happyrob@happyrobotlabs.com:~/public_html/cjwoodall/