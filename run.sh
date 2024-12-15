#!/bin/bash

docker build -t foo-build .

docker run --rm -it -v ./build:/build foo-build