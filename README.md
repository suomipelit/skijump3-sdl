# Ski Jump International v3 (SDL2 port)

[![Build Status](https://api.travis-ci.org/suomipelit/skijump3-sdl.svg?branch=master)](https://travis-ci.org/suomipelit/skijump3-sdl)
[![Downloads](https://img.shields.io/github/downloads/suomipelit/skijump3-sdl/total.svg)](https://github.com/suomipelit/skijump3-sdl/releases)
[![Latest release](http://img.shields.io/github/release/suomipelit/skijump3-sdl.svg)](https://github.com/suomipelit/skijump3-sdl/releases/latest)

[Repository](https://github.com/suomipelit/skijump3-sdl)

![Cover](https://github.com/suomipelit/suomipelit.github.io/blob/master/gifs/sj3.gif)

[Skijump International v3 website](https://www.nomasi.com/sj3/)

Huge thanks for original author Ville Könönen for open-sourcing this
absolute classic gem from the good old DOS days.

[Original
Credits](https://github.com/suomipelit/skijump3-sdl/blob/master/CREDITS.TXT)

This repository is for SDL2 port. If you would like to build or play
Skijump International v3 on DOS, take a look at [open-sourced DOS
version](https://github.com/suomipelit/skijump3) instead.

## Playing

[Original Quick
Guide](https://github.com/suomipelit/skijump3-sdl/blob/master/QUICK.TXT)

**Note:** Please note that hill records from open sourced version are
not accepted in any of the hiscore lists. You need to play [original
closed DOS version](https://www.nomasi.com/sj3/download.html) to
qualify.

## Differences compared to DOS version

Port attempts to be carbon copy of original DOS version, even to such
extent that you can share configuration files. Only minor bugs like
some buffer overflows have been fixed.

### Additional port related shortkeys

| Key | Description |
| --- | --- |
| Alt+Enter | Toggle fullscreen |
| Alt+(Keypad) Plus | Increase window size |
| Alt+(Keypad) Minus | Decrease window size |
| Alt+R | Reset window if stretched |

## Build

Build has been tested on Windows 10 and Linux using Free Pascal
Compiler.

Compilation process on Ubuntu is following

``` sh
# Install compiler and SDL2
$ sudo apt-get install fpc libsdl2-dev

# Clone Pascal SDL2 headers
$ git clone https://github.com/ev1313/Pascal-SDL-2-Headers

# Compile in Turbo Pascal mode
$ fpc -Mtp -Fu./Pascal-SDL-2-Headers/ SJ3.PAS
```

You can find full instructions how to compile Pascal SDL2 applications
from ["Free Pascal meets
SDL"](https://www.freepascal-meets-sdl.net/sdl-tutorials/) also for
Windows. You can either install just Free Pascal Compiler or Lazarus
IDE which bundles editor and the compiler.

## Releases

**[Version 3](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp3) - 2020-11-22**

- Graceful shutdown with save when closing with window close button

**[Version 2](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp2) - 2020-11-08**

- [Improve input handling of special keys](https://github.com/suomipelit/skijump3-sdl/pull/13)
- [Fix pausing after landing with Caps Lock or Shift on](https://github.com/suomipelit/skijump3-sdl/pull/14)

**[Version 1](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp1) - 2020-06-16**

- Initial release
