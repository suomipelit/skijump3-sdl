# Ski Jump International v3 (SDL2 port)

![Build](https://github.com/suomipelit/skijump3-sdl/workflows/Build/badge.svg)
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
| Alt+A | Toggle 4:3 aspect ratio |

### Command line parameters

| Command | Short |  Description |
| --- | --- | --- |
| --sw-rendering | -s | Enforce SW rendering |

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

**[WIP - Version 5](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp4) - TBA**

- [More accurate frame rate limiter](https://github.com/suomipelit/skijump3-sdl/pull/27)
- [Make LMaara global](https://github.com/suomipelit/skijump3-sdl/pull/26)
- [Support keys G to L in menus](https://github.com/suomipelit/skijump3-sdl/pull/25)
- [Show wind location in options](https://github.com/suomipelit/skijump3-sdl/pull/24)
- [Fix box title name for CPU jumper select](https://github.com/suomipelit/skijump3-sdl/pull/23)
- [Allow resetting wind in practice](https://github.com/suomipelit/skijump3-sdl/pull/22)
- [Add invisible background support to KO pairs screen](https://github.com/suomipelit/skijump3-sdl/pull/21)

**[Version 4](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp4) - 2020-12-20**

- [Add support for aspect ratio correction](https://github.com/suomipelit/skijump3-sdl/pull/15)
- Support SW rendering with command line parameter

**[Version 3](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp3) - 2020-11-22**

- Graceful shutdown with save when closing with window close button

**[Version 2](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp2) - 2020-11-08**

- [Improve input handling of special keys](https://github.com/suomipelit/skijump3-sdl/pull/13)
- [Fix pausing after landing with Caps Lock or Shift on](https://github.com/suomipelit/skijump3-sdl/pull/14)

**[Version 1](https://github.com/suomipelit/skijump3-sdl/releases/tag/sj313-sp1) - 2020-06-16**

- Initial release
