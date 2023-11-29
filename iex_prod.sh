#!/bin/bash

set -e

fly ssh console --pty --select -C "/app/bin/kart_vids remote"
