#!/bin/bash

################################
### CHANGE BACKGROUND SCRIPT ###
################################

# if optional argument is passed, check if is image and set it as background
# if no argument go to wallpaper directory specified in this script and pick random one

#############
# FUNCTIONS #
#############

print_usage() {
    echo "Usage: $0 [IMAGE_PATH]"
    echo "If IMAGE_PATH is provided, validates and sets it as wallpaper."
    echo "Otherwise, selects a random wallpaper from a specific folder based on time of day."
}

check_installed() {
    if ! command -v $1 &>/dev/null; then
        echo >&2 "'$1' not found. Please install it."
        exit 1
    fi
}

check_arg() {
    # if argument supplied is file and if it is an image
    if [[ ! -f "$1" ]]; then
        echo >&2 "File '$1' does not exist"
        exit 1
    fi

    if ! magick identify "$1"; then
        echo >&1 "'$1' is not a valid image"
        exit 1
    fi

    # if file is valid, use it as WALLPAPER_PATH
    WALLPAPER_PATH="$1"
}

##############
### SCRIPT ###
##############

# Checking to ensure successful run
check_installed "wallust"
check_installed "magick"
check_installed "swww"
check_installed "jq"

ABSOLUTE_PATH=$(realpath "$0")
DIR_NAME=$(dirname "$ABSOLUTE_PATH")
ENV_FILE="$DIR_NAME/.env"
WALLUST_CACHE="$HOME/.cache/wallust"

if [[ ! -f $ENV_FILE ]]; then
    echo ".env file not found!"
    exit
fi

source "$ENV_FILE"

if [[ $# -eq 1 ]]; then
    # print help and exit
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        print_usage
        exit
    fi
    # if argument (image for background) was supplied, check if valid
    check_arg $1
else
    if [[ $TIME_SPECIFIC_FOLDERS == true ]]; then
        # else pick a folder according to current hour of day
        CURRENT_HOUR="$((10#$(date +%H)))"
        if [[ $CURRENT_HOUR -ge 20 || $CURRENT_HOUR -lt 05 ]]; then
            # 20:00 - 05:00
            WALLPAPER_DIR="$WALLPAPER_DIR/night"
        elif [[ $CURRENT_HOUR -ge 05 && $CURRENT_HOUR -lt 13 ]]; then
            # 05:00 - 13:00
            WALLPAPER_DIR="$WALLPAPER_DIR/morning"
        elif [[ $CURRENT_HOUR -ge 13 && $CURRENT_HOUR -lt 20 ]]; then
            # 13:00 - 20:00
            WALLPAPER_DIR="$WALLPAPER_DIR/afternoon"
        fi
    fi

    # pick one random file
    # adjust depth=1 if you only want top-level images and depth>1 if you want to descend into subdirectories
    WALLPAPER_PATH="$(find "$WALLPAPER_DIR" -maxdepth 2 -type f -follow | shuf -n 1)"
fi

# pick predefined color scheme (optional)
if [[ ! -z ${SPECIFIC_WALLUST_THEME+x} ]]; then
    # uses the default wallust.toml config file
    wallust theme $SPECIFIC_WALLUST_THEME --quiet
fi

if [[ -z ${SPECIFIC_WALLUST_THEME+x} ]]; then
    # if no specific theme defined, generate color scheme and set its colors
    wallust run $WALLPAPER_PATH --config-file ~/.config/wallust/change_background.toml
else
    # generate but dont set global theme colors
    wallust run $WALLPAPER_PATH --skip-sequences --config-file ~/.config/wallust/change_background.toml
fi

# restart waybar
# (you can comment this out, if you run this script first and then start waybar)
if [[ $RESTART_WAYBAR == true ]]; then
    kill -s SIGUSR2 $(pgrep waybar)
fi

WALLPAPER_CACHE="$HOME/.cache/wallpapers"
mkdir -p $WALLPAPER_CACHE
CACHED_WALLPAPER="$WALLPAPER_CACHE/$(basename $WALLPAPER_PATH)"

IMAGE_WIDTH=$(($RESOLUTION_W - $IMAGE_MARGIN))
IMAGE_HEIGHT=$(($RESOLUTION_H - $IMAGE_MARGIN))

# only generate if file does not yet exist
if [[ ! -e $CACHED_WALLPAPER ]]; then
    magick $WALLPAPER_PATH \
        -resize ${IMAGE_WIDTH}x${IMAGE_HEIGHT} \
        -background "$(jq -r ".background" $WALLPAPER_CACHE/colors.json)" \
        -compose copy \
        -gravity center \
        -extent ${RESOLUTION_W}x${RESOLUTION_H} \
        $CACHED_WALLPAPER
fi

swww img --transition-type center $CACHED_WALLPAPER
