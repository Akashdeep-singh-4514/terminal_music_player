#!/bin/bash

if [ -f /etc/arch-release ]; then
    PKG_MANAGER="pacman -S --needed --noconfirm"
    echo "Detected Arch Linux."
elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    PKG_MANAGER="apt install -y"
    echo "Detected Debian/Ubuntu."
    sudo apt update
else
    echo "Error: Unsupported distribution."
    exit 1
fi

echo "Installing dependencies (mpv, yt-dlp, cava, kitty)..."
sudo $PKG_MANAGER mpv yt-dlp cava kitty

KITTY_CONF="$HOME/.config/kitty/kitty.conf"
mkdir -p "$(dirname "$KITTY_CONF")"
touch "$KITTY_CONF"

if ! grep -q "allow_remote_control yes" "$KITTY_CONF"; then
    echo "allow_remote_control yes" >> "$KITTY_CONF"
    echo "Enabled remote control in kitty.conf"
fi


echo "Creating /usr/local/bin/play..."

sudo bash -c 'cat << "EOF" > /usr/local/bin/play
#!/bin/bash

QUERY="$*"

if [ -z "$QUERY" ]; then
    echo "Usage: play <song name or URL>"
    exit 1
fi

# Check if current terminal is Kitty
if [ "$TERM" != "xterm-kitty" ]; then
    echo "Warning: This script works best inside Kitty terminal."
fi

# Format the URL
if [[ "$QUERY" == http* ]]; then
    URL="$QUERY"
else
    URL="ytdl://ytsearch1:$QUERY"
fi

# We use Kitty windows instead of tmux panes
# 1. Launch CAVA in a new pane (top)
# 2. Run MPV in the current pane (bottom)
# 3. When MPV exits, close the CAVA pane

# Get current window id to manage the split
original_window_id=$KITTY_WINDOW_ID

# Launch CAVA in a horizontal split
kitty @ launch --location=hsplit --title="Visualizer" cava

# Run MPV in the main pane
echo "Playing: $QUERY"
mpv --no-video --ytdl-format="bestaudio/best" "$URL"

# Cleanup: Close the visualizer pane when music stops
# This sends a close signal specifically to the window we opened
kitty @ close-window --match title:Visualizer
EOF'

sudo chmod +x /usr/local/bin/play

echo "---"
echo "Setup complete! Since you use Kitty, make sure to restart Kitty for changes to take effect."
echo "Usage: play \"sanson ki mala\""