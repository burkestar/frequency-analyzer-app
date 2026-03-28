# Frequency Analyzer — iOS Instrument Tuner

Real-time audio frequency analyzer and instrument tuner for iPhone. Detects pitch from the microphone and displays the frequency in Hz, the closest musical note (e.g., A4, E2, C#3), and a visual gauge showing how sharp or flat you are in cents.

## Features

- Real-time pitch detection using the YIN algorithm (autocorrelation-based, sub-Hz accuracy)
- Frequency display in Hz with target note frequency
- Musical note identification with octave number (C0–B8)
- Tuner gauge showing ±50 cents deviation (green when in tune)
- Dark UI optimized for stage/practice use
- Supports frequencies from ~50 Hz to ~2000 Hz (covers guitar, bass, ukulele, violin, voice, etc.)

## Requirements

- **Mac** with Xcode 16+ installed
- **iPhone** running iOS 17 or later
- **Apple Developer account** (free account works for personal device testing)
- USB cable or same Wi-Fi network (for wireless deployment)

## Setup Steps

### 1. Open the project in Xcode

```bash
open FrequencyAnalyzer.xcodeproj
```

### 2. Configure signing

1. In Xcode, select the **FrequencyAnalyzer** project in the left sidebar
2. Select the **FrequencyAnalyzer** target
3. Go to the **Signing & Capabilities** tab
4. Check **Automatically manage signing**
5. Select your **Team** from the dropdown
   - If you don't have a team, click **Add Account...** and sign in with your Apple ID
   - A free Apple ID works — you don't need a paid developer account

### 3. Connect your iPhone

- Plug your iPhone into your Mac via USB cable, **or**
- Enable wireless debugging: on your iPhone go to **Settings → Developer → Enable wireless debugging** (requires initial USB pairing)

### 4. Select your device

- In Xcode's toolbar, click the device dropdown (next to the scheme name)
- Select your iPhone from the list

### 5. Trust the developer on your iPhone (first time only)

If this is your first time running a dev-signed app on this device:

1. Build and run from Xcode (⌘R) — it will install but may fail to launch
2. On your iPhone, go to **Settings → General → VPN & Device Management**
3. Tap your Apple ID under "Developer App"
4. Tap **Trust** and confirm
5. Run again from Xcode (⌘R)

### 6. Grant microphone permission

When the app launches for the first time, it will ask for microphone access. Tap **Allow**. The app cannot function without microphone permission.

### 7. Use the tuner

- Play a note on your instrument or sing/hum into the phone
- The app displays the detected note, frequency, and tuning accuracy
- The gauge needle moves left (flat) or right (sharp) — center is in tune
- Green = in tune (within ±5 cents), yellow = close, orange = off

## Troubleshooting

| Problem | Solution |
|---|---|
| "Untrusted Developer" alert | Settings → General → VPN & Device Management → Trust |
| No pitch detected | Make sure microphone permission is granted; play louder or closer to the phone |
| App won't install | Check that your deployment target matches your iOS version (currently set to iOS 17.0) |
| No devices shown in Xcode | Reconnect USB cable; ensure iPhone is unlocked; try restarting Xcode |

## Project Structure

```
FrequencyAnalyzer/
├── FrequencyAnalyzerApp.swift    # App entry point
├── Audio/
│   ├── AudioEngine.swift         # AVAudioEngine mic capture
│   └── PitchDetector.swift       # YIN pitch detection algorithm
├── Model/
│   ├── TunerData.swift           # Tuner state data
│   └── NoteMapper.swift          # Hz → note name + cents
├── ViewModel/
│   └── TunerViewModel.swift      # Observable bridge (audio → UI)
└── Views/
    ├── TunerView.swift           # Main screen layout
    ├── TunerGauge.swift          # Cents deviation gauge
    ├── NoteDisplay.swift         # Note name + octave
    └── FrequencyDisplay.swift    # Hz readout
```
