all: build test

build:
	jekyll build

test:
	bundle exec htmlproofer ./_site

deploy:
	rsync -r _site/* $(DEPLOY_URL)
