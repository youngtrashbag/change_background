# change_background

A script to change your background and colorscheme on your wayland compositor

> Note: I use sway, this has not been tested on other window managers

## Prerequisites

This script depends on these programs:

- [swww](https://github.com/LGFae/swww)
- [wallust](https://codeberg.org/explosion-mental/wallust)
- [imagemagick](https://imagemagick.org/)
- [jq](https://github.com/jqlang/jq)

Install them on Arch Linux via

`pacman -S swww imagemagick jq`

`yay -S wallust` or `cargo install wallust`

## Installation

I recommend adding the script to your path. Personally, I do this as follows:

### Script

1. `mkdir -p ~/.local/bin/`

2. then append this line to your `.profile`
    `export PATH=$PATH:$HOME/.local/bin/`

3. `ln -s ./change_background.sh ~/.local/bin/change_background`

### Config

1. `cp .env.example .env`
2. `cp -r wallust/* ~/.config/wallust`

## Usage

simply call `change_background` to pick a random background

or if you have an image you want to set, call `change_background ./wallpaper.png`

add the following to your `.sway/config` file

```
exec swww-daemon
exec change_background
```

## Customising

The script is extensive by default.
I encourage you to change the defaults and customise your experience

Also make sure to add your own wallust [templates](https://codeberg.org/explosion-mental/wallust-templates)
to apply the new colorscheme to your terminal, waybar etc.

## Contributions

Any contributions welcome!

I am a beginner in bash scripting and honestly had to look up how to do everything.

Upon finishing I asked *Qwen Coder* to check the code and give me feedback.
(So its not vibe-coded, but vibe-checked I suppose :) )
