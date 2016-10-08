all: build test

build:
	jekyll build

test:
	bundle exec htmlproofer ./_site

deploy:
	sshpass -p "$PASS" rsync -r _site/* $(DEPLOY_URL)
