#!/bin/bash

# Detect the OS/Package Manager
if [ -f /etc/arch-release ]; then
    PKG_MANAGER="pacman -S --needed --noconfirm"
    echo "Detected Arch Linux."
elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    PKG_MANAGER="apt install -y"
    echo "Detected Debian/Ubuntu."
    sudo apt update
else
    echo "Error: Unsupported distribution. This script supports Arch and Debian/Ubuntu."
    exit 1
fi

echo "Starting setup for yt-music visualizer..."

# 1. Install Dependencies
echo "Installing dependencies..."
sudo $PKG_MANAGER yt-dlp mpv tmux ffmpeg cava


# 2. Configure .tmux.conf
if [ ! -f ~/.tmux.conf ] || ! grep -q "set -g mouse on" ~/.tmux.conf; then
    echo "set -g mouse on" >> ~/.tmux.conf
    echo "Mouse mode enabled in .tmux.conf"
fi

# 3. Create the 'play' executable in /usr/local/bin/
echo "Creating /usr/local/bin/play..."

sudo bash -c 'cat << "EOF" > /usr/local/bin/play
#!/bin/bash

QUERY="$*"

if [ -z "$QUERY" ]; then
    echo "Usage: play <song name or URL>"
    exit 1
fi

if [ -n "$TMUX" ]; then
    tmux split-window -v -p 35 "cava"
    if [[ "$QUERY" == http* ]]; then
        mpv --no-video --ytdl-format="bestaudio/best" --no-playlist "$QUERY"
    else
        mpv --no-video --ytdl-format="bestaudio/best" "ytdl://ytsearch1:$QUERY"
    fi
else
    SESSION_NAME="yt_music"

    tmux new-session -d -s "$SESSION_NAME" \
        "mpv --no-video --ytdl-format='\''bestaudio/best'\'' '\''ytdl://ytsearch1:$QUERY'\''; tmux kill-session -t $SESSION_NAME"

    tmux split-window -v -p 35 -t "$SESSION_NAME" "cava"

    tmux select-pane -t 0

    tmux attach-session -t "$SESSION_NAME"
fi
EOF'

# 4. Set permissions
sudo chmod +x /usr/local/bin/play

echo "---"
echo "Setup complete! You can now use the 'play' command from anywhere."
echo "Example: play \"never gonna give you up\""
