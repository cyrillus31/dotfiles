#!/bin/bash

# NOTE: append_path function comes from .shellrc.sh

# add yandex golang version to PATH
YANDEX_GO_VERSION="/opt/homebrew/opt/go@1.23/bin"
[ -d $YANDEX_GO_VERSION ] && append_path $YANDEX_GO_VERSION
