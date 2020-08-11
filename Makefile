LEKTOR_SERVER_FLAGS=-h 127.0.0.1
# minify javascript assets, compile scss assets
LEKTOR_PLUGIN_FLAGS=-f scss
LEKTOR_DEPLOY_FLAGS=

all: build

.ONESHELL:
install:
	if hash apt-get 2>/dev/null; then
	  sudo apt-get update -qq >/dev/null && sudo apt-get install -qq apt-utils imagemagick python3-pip python3-setuptools gcc git-lfs
	elif hash pacman 2>/dev/null; then
	  sudo pacman -Syu imagemagick python-pip glibc lib32-glibc gcc git-lfs --noconfirm
	elif hash dnf 2>/dev/null; then
	  sudo dnf install -y ImageMagick python3-pip gcc git-lfs
	else
	  echo -e "Please install Imagemagick, python3-pip git-lfs and gcc"
	fi
	sudo pip3 install wheel  --upgrade
	sudo pip3 install lektor --upgrade

build:
	if python3 -m lektor --version 2>/dev/null; then
	  python3 -m lektor build $(LEKTOR_PLUGIN_FLAGS)
	else
	  lektor build $(LEKTOR_PLUGIN_FLAGS)
	fi

server:
	if python3 -m lektor --version 2>/dev/null; then
	  python3 -m lektor server $(LEKTOR_SERVER_FLAGS) $(LEKTOR_PLUGIN_FLAGS)
	else
	  lektor server $(LEKTOR_SERVER_FLAGS) $(LEKTOR_PLUGIN_FLAGS)
	fi

deploy:
	lektor clean --yes
	lektor plugin flush-cache
	lektor build $(LEKTOR_PLUGIN_FLAGS) $(LEKTOR_DEPLOY_FLAGS)
	lektor deploy $(LEKTOR_PLUGIN_FLAGS) $(LEKTOR_DEPLOY_FLAGS)

pull:
	if git config remote.github.url > /dev/null; then
	  git pull github $(git branch --show-current)
	else
	  git remote add github git@github.com:c3woc/c3woc-website.git
	  git pull github $(git branch --show-current)
	fi
	if git config remote.gitea.url > /dev/null; then
	  git pull gitea $(git branch --show-current)
	else
	  git remote add gitea gitea@gitea.see-base.de:C3WOC/c3woc-webseite.git
	  git pull gitea $(git branch --show-current)
	fi
	git pull origin $(git branch --show-current)

push:
	rm .lfsconfig
	if git config remote.gitea.url > /dev/null; then
	  git push gitea $(git branch --show-current)
	else
	  git remote add gitea gitea@gitea.see-base.de:C3WOC/c3woc-webseite.git
	  git push gitea $(git branch --show-current)
	fi
	if git config remote.github.url > /dev/null; then
	  git push github $(git branch --show-current)
	else
	  git remote add github git@github.com:c3woc/c3woc-website.git
	  git push github $(git branch --show-current)
	fi
	git restore .lfsconfig
