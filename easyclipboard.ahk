#NoEnv
#SingleInstance Force
SetBatchLines, -1
SendMode Input
SetTitleMatchMode, 2

; === Config ===
subtitleFile := "C:\Path\To\Your\Subtitle.srt"  ; Replace with your subtitle file
audioOutputFolder := "C:\Path\To\OutputFolder"  ; Replace with desired output folder
audioDevice := "CABLE Output (VB-Audio Virtual Cable)"  ; Optional: Replace with your audio device
; To list available devices, run this in command line:
; ffmpeg -list_devices true -f dshow -i dummy
delayMs := 0

; === Get extension ===
ext := SubStr(subtitleFile, InStr(subtitleFile, ".", false, 0) + 1)

; === Hotkey 1: Copy subtitle text only ===
^+c::  ; Ctrl + Shift + C
{
    currentMs := GetCurrentMPC_HC_TimeMs(delayMs)
    if (currentMs < 0)
        return

    text := GetSubtitleTextAtTime(subtitleFile, ext, currentMs)
    if (text != "")
    {
        Clipboard := text
        ToolTip, Copied: %text%
        SetTimer, RemoveToolTip, -1500
    }
}
return

; === Hotkey 2: Generate audio from subtitle ===
^+x::  ; Ctrl + Shift + X
{
    currentMs := GetCurrentMPC_HC_TimeMs(delayMs)
    if (currentMs < 0)
        return

    startMs := 0
    endMs := 0
    text := GetSubtitleTextAtTime(subtitleFile, ext, currentMs, startMs, endMs)
    if (text = "")
    {
        ToolTip, No subtitle line found.
        SetTimer, RemoveToolTip, -1000
        return
    }

    durationMs := endMs - startMs
    if (durationMs <= 0)
        return

    FormatTime, timestamp,, yyyyMMdd_HHmmss
    audioFile := audioOutputFolder . "\jpaudio_" . timestamp . ".mp3"

    startMsForAudio := startMs - delayMs
    if (startMsForAudio < 0)
        startMsForAudio := 0
    startSec := Round(startMsForAudio / 1000, 2)
    durationSec := Round(durationMs / 1000, 2)

    videoFile := GetCurrentVideoPath()
    if (videoFile = "")
    {
        ToolTip, Failed to get video path.
        SetTimer, RemoveToolTip, -2000
        return
    }

    RunWait, %ComSpec% /C ffmpeg -ss %startSec% -t %durationSec% -i "%videoFile%" -vn -map 0:a:m:language:jpn -af aresample=async=1:first_pts=0 -acodec libmp3lame -qscale:a 5 "%audioFile%" 2>nul,, Hide

    if FileExist(audioFile)
    {
        FileCopyToClipboard(audioFile)
        ToolTip, Audio Created and Copied: %audioFile%
        SetTimer, RemoveToolTip, -2000
    }
    else
    {
        ToolTip, Audio creation failed.
        SetTimer, RemoveToolTip, -2000
    }
}
return

RemoveToolTip:
ToolTip
return

GetCurrentMPC_HC_TimeMs(offsetMs)
{
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("GET", "http://127.0.0.1:13579/variables.html", false)
    http.Send()
    response := http.ResponseText
    if !RegExMatch(response, "(\d{2}):(\d{2}):(\d{2})", m)
        return -1
    h := m1, m := m2, s := m3
    return (((h*60 + m)*60 + s)*1000) + offsetMs
}

GetCurrentVideoPath()
{
    http := ComObjCreate("MSXML2.XMLHTTP")
    http.Open("GET", "http://127.0.0.1:13579/variables.html", false)
    http.Send()
    if (http.Status != 200)
        return ""
    response := http.ResponseText
    if RegExMatch(response, "<p id=""filepath"">([A-Z]:\\[^<]+)</p>", match)
        return match1
    return ""
}

GetSubtitleTextAtTime(file, ext, currentMs, ByRef outStart := 0, ByRef outEnd := 0)
{
    FileRead, raw, *P65001 %file%
    textCombined := ""
    if (ext = "srt")
    {
        blocks := StrSplit(raw, "`r`n`r`n")
        for _, block in blocks
        {
            if RegExMatch(block, "(\d{2}):(\d{2}):(\d{2}),(\d{3})\s+-->\s+(\d{2}):(\d{2}):(\d{2}),(\d{3})\s+([\s\S]+)", m)
            {
                start := ((m1*3600 + m2*60 + m3)*1000 + m4)
                end   := ((m5*3600 + m6*60 + m7)*1000 + m8)
                if (currentMs >= start && currentMs <= end)
                {
                    line := RegExReplace(m9, "(\r?\n)+", " ")
                    line := RegExReplace(line, "{[^}]+}", "")
                    line := RegExReplace(line, "\\[Nn]", " ")
                    textCombined .= line " "
                    outStart := start
                    outEnd := end
                }
            }
        }
    }
    else if (ext = "ass")
    {
        inEvents := false
        Loop, Parse, raw, `n, `r
        {
            line := A_LoopField
            if (!inEvents)
            {
                if (Trim(line) = "[Events]")
                    inEvents := true
                continue
            }
            if (SubStr(line, 1, 9) = "Dialogue:")
            {
                fields := StrSplit(line, ",", " ,", 10)
                start := TimeToMs(fields[2])
                end := TimeToMs(fields[3])
                text := fields[10]
                if (currentMs >= start && currentMs <= end)
                {
                    text := RegExReplace(text, "{[^}]+}", "")
                    text := RegExReplace(text, "\\[Nn]", " ")
                    textCombined .= text " "
                    outStart := start
                    outEnd := end
                }
            }
        }
    }
    return Trim(textCombined)
}

TimeToMs(time) {
    if RegExMatch(time, "(\d+):(\d{2}):(\d{2})[.:](\d+)", m)
        return ((m1*3600 + m2*60 + m3)*1000 + SubStr(m4 "00", 1, 3))
    return 0
}

FileCopyToClipboard(file) {
    ComObjCreate("Shell.Application").Namespace(0).ParseName(file).InvokeVerb("Copy")
}
