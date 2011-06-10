#!/bin/bash

mplayer -identify "$1" -ao null -vo null -frames 0 2>/dev/null

