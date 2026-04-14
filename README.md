# Terminal Music Player (Arch/Debian Linux Only)

This project installs a `yt` command that lets you play YouTube audio in the terminal with `mpv` and a `cava` visualizer inside `tmux`.

## Arch/debian Linux only

`script.sh` is designed specifically for Arch Linux and debian linux

## What the setup script does

Running `script.sh` will:

- Install required packages with `pacman`: `yt-dlp`, `mpv`, `tmux`, `ffmpeg`, `cava`
- Enable tmux mouse mode in `~/.tmux.conf`
- Create `/usr/local/bin/play` and make it executable

## Usage

1. Make the setup script executable:

```bash
chmod +x script.sh
```

2. Run the setup:

```bash
./script.sh
```

3. Use the new command:

```bash
play "never gonna give you up"
```

You can also pass a direct YouTube URL:

```bash
play "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

## Notes

- The setup uses `sudo` for package installation and writing `/usr/local/bin/play`.

## Controls (MPV Pane)
Key	                 Action
Space	               Play / Pause
Left/Right	         Seek 5 seconds
9 / 0	               Volume Down / Up
q	                   Quit and Close Session


## recommended 
be familiar to tmux

## quick fix 
incase you close terminal without quiting player 
```tmux kill-session -t yt_music```
