# Anki Audio + Subtitle Extractor (AHK Script for MPC-HC)

This AutoHotkey script helps you quickly create Anki cards by copying subtitle text and extracting audio to clipboard from the currently playing video in MPC-HC.
Audio recording only works for Japanese if you want to change to other languages change: language:jpn
DelayMs adjusting is available in case your subtitles are off.
## 🔧 What It Does
 
- Press `Ctrl + Shift + C` to **copy the current subtitle** text to clipboard.
- Press `Ctrl + Shift + X` to **extract audio** (based on subtitle timing) and copy the MP3 file to clipboard.

Watch a short demo: [YouTube Video (Unlisted)](https://youtu.be/1VVMs4Wx7nY)

---

## ✅ Requirements

- [AutoHotkey v1](https://www.autohotkey.com/)
- [FFmpeg](https://ffmpeg.org/download.html) (must be in system PATH)
- [MPC-HC](https://mpc-hc.org/) with the web interface enabled:
  - Go to `Options > Player > Web Interface`
  - Check **"Listen on port"** (default: `13579`)
- Japanese subtitles in `.srt` or `.ass` format (externally loaded in MPC-HC)
- **VB-Audio Virtual Cable** (optional, but useful if your system recording setup doesn't work)

---

## 🔉 Virtual Audio Cable Setup (Optional)

If audio isn't recorded correctly, install and configure [VB-Audio Virtual Cable](https://vb-audio.com/Cable/).

1. Set **Output device** to: `CABLE In` (Windows Sound Settings)
2. Go to **Recording > CABLE Output > Properties > Listen Tab** and check:
   - ✅ *"Listen to this device"*
   - Set playback device to your usual speakers/headphones

![Sound Settings](./screenshots/audio_output.png)
![Cable Output Properties](./screenshots/cable_properties.png)

> You can list available audio devices using the command:  
> `ffmpeg -list_devices true -f dshow -i dummy`

---

## 🎯 Customize Hotkeys

The script uses default hotkeys:
- `Ctrl + Shift + C` — copy subtitle text
- `Ctrl + Shift + X` — extract audio

Want to use mouse side buttons instead?
Replace these hotkeys in the script:

```autohotkey
^+c:: ; Ctrl + Shift + C
```
with
```autohotkey
XButton2::
```
and

```autohotkey
^+x:: ; Ctrl + Shift + X
```
with
```autohotkey
XButton1::
```

---

## 🧠 Notes

- This script uses MPC-HC's web interface to extract the current timestamp and video path.
- Audio is extracted with `ffmpeg` using the Japanese audio stream if available.

---

## 📂 Folder Structure

```
.
├── easyclipboard.ahk
├── README.md
└── screenshots
    ├── audio_output.png
    └── cable_properties.png
```

---

## 📝 License

MIT License (optional)

---
