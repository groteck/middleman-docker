# Docker Machine with ruby, node, open-jdk and phantomjs

I use this machine for develop middleman applications, with bower angularjs and
protractor.

## For beginners

This machine use [docker](https://www.docker.com/), so please
[install](https://docs.docker.com/installation/#installation) before run usage instructions.

## Usage

``` bash
git clone git@github.com:groteck/middleman-docker.git
cd middleman-docker
sudo docker build -t=machine-name . %% sudo docker run --rm -it middleman bash
```
