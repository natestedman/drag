# `drag`
[![Build Status](https://travis-ci.org/natestedman/drag.svg?branch=master)](https://travis-ci.org/natestedman/Attributed)
[![License](https://img.shields.io/badge/license-Creative%20Commons%20Zero%20v1.0%20Universal-blue.svg)](https://creativecommons.org/publicdomain/zero/1.0/)

A command-line utility for OS X drag-and-drop.

## Installation
Download `drag.pkg` from [Releases](https://github.com/natestedman/drag/releases).

## Usage
```bash
drag [files to drag]...
```

This creates a window with a drag source for the files passed as arguments, centered on the current cursor position. To drag, just click.

The program will exit and the window will disappear when dragging completes, or if the escape key is pressed.

## Building a Package
A `.pkg` installer can be built with `make package`. This requires that a Developer ID is installed.
