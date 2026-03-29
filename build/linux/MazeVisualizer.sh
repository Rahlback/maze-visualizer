#!/bin/sh
printf '\033c\033]0;%s\a' MazeVisualizer
base_path="$(dirname "$(realpath "$0")")"
"$base_path/MazeVisualizer.x86_64" "$@"
