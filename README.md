<h3 align="center">SwiftyRecorder</h3>
<p align="center">A Swift-based screen recording API for macOS</p>

## Requirements:
* macOS 13+
* Xcode 15+
* Swift 5.7+

## Installation:
Add the following to your `Package.swift`:

```swift
.package(url: "https://github.com/krishpranav/SwiftyRecorder", from: "1.0.0")
```

## Basic Usage:
```swift
import Foundation
import SwiftyRecorder

let recorder = SwiftyRecorder()

let screens = try await SwiftyRecorder.Devices.screens()

guard let screen = screens.first else {
    exit(1)
}

try await recorder.startRecording(
    target: .screen,
    options: RecordingOptions(
        destination: URL(fileURLWithPath: "./recording.mp4"),
        targetID: screen.id
    )
)

try await Task.sleep(nanoseconds: 5 * 1_000_000_000)

try await recorder.stopRecording()
```
