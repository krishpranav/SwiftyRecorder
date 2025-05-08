//
//  Utils.swift
//  SwiftyRecorder
//
//  Created by Krisna Pranav on 08/05/25.
//

import AVFoundation
import ScreenCaptureKit

internal func initializeCGS() {
    CGMainDisplayID()
}

extension SwiftyRecorder {
    @available(macOS 12.3, *)
    public static var hasPermissions: Bool {
        get async {
            do {
                _ = try await SCShareableContent.current
                return true
            } catch {
                return false
            }
        }
    }
}

extension CMSampleBuffer {
    @available(macOS 10.15, *)
    public func adjustTime(by offset: CMTime) -> CMSampleBuffer? {
        guard self.formatDescription != nil, offset.value > 0 else {
            return nil
        }

        do {
            var timingInfo = try self.sampleTimingInfos()

            for index in 0..<timingInfo.count {
                timingInfo[index].decodeTimeStamp = timingInfo[index].decodeTimeStamp - offset

                timingInfo[index].presentationTimeStamp = timingInfo[index].presentationTimeStamp - offset
            }

            return try .init(copying: self, withNewTiming: timingInfo)
        } catch {
            return nil
        }
    }
}

extension SwiftyRecorder.Error {
    public var localizedDescription: String {
        switch self {
        case .couldNotStartStream(let error):
            let errorReason: String

            if let error = error as? SwiftyRecorder.Error {
                errorReason = ": \(error.localizedDescription)"
            } else if let error {
                errorReason = ": \(error.localizedDescription)"
            } else {
                errorReason = "."
            }

            return "[LOG]: can not start recording\(errorReason)"
        case .unsupportedFileExtension(let fileExtension, let isAudioOnly):
            if isAudioOnly {
                return "[LOG]: invalid file extension. Only .m4a is supported for audio recordings. received: \(fileExtension)."
            }

            return "[LOG][ERROR]: invalid file extension. Only .mp4, .mov and .m4v are supported for video recordings. received: \(fileExtension)."
        case .invalidFileExtension(let fileExtension, let videoCodec):
            return "[LOG][ERROR]: invalid file extension. .\(fileExtension) does not support \(videoCodec)."
        case .microphoneNotFound(let microphoneId):
            return "[LOG][ERROR]: microphone with id \(microphoneId) not found"
        case .noDisplaysConnected:
            return "[LOG][ERROR]: at least one display should be connected."
        case .noTargetProvided:
            return "[LOG][ERROR]: no target provider."
        case .recorderAlreadyStarted:
            return "[LOG][ERROR]: recorder has already started. Each recorder instance can only be started once."
        case .recorderNotStarted:
            return "[LOG][ERROR]: recorder needs to be started first."
        case .targetNotFound(let targetId):
            return "[LOG][ERROR]: target with id \(targetId) not found."
        case .noPermissions:
            return "[LOG][ERROR]: missing screen capture permissions."
        case .unsupportedVideoCodec:
            return "[LOG][ERROR]: videocodec not supported."
        case .couldNotAddInput(let inputType):
            return "[LOG][ERROR]: could not add \(inputType) input."
        case .unknown(let error):
            return "[LOG][ERROR]: an unknown error has occurred: \(error.localizedDescription)"
        }
    }
}

extension SwiftyRecorder.VideoCodec {
    public static func fromRawValue(_ rawValue: String) throws -> SwiftyRecorder.VideoCodec {
        switch rawValue {
        case "h264":
            return .h264
        case "hevc":
            return .hevc
        case "proRes422":
            return .proRes422
        case "proRes4444":
            return .proRes4444
        default:
            throw SwiftyRecorder.Error.unsupportedVideoCodec
        }
    }

    var asString: String {
        switch self {
        case .h264:
            return "h264"
        case .hevc:
            return "hevc"
        case .proRes422:
            return "proRes422"
        case .proRes4444:
            return "proRes4444"
        }
    }

    var asAVVideoCodec: AVVideoCodecType {
        switch self {
        case .h264:
            return .h264
        case .hevc:
            return .hevc
        case .proRes422:
            return .proRes422
        case .proRes4444:
            return .proRes4444
        }
    }
}

final class Activity {
    private let activity: NSObjectProtocol

    init(
        _ options: ProcessInfo.ActivityOptions = [],
        reason: String
    ) {
        self.activity = ProcessInfo.processInfo.beginActivity(options: options, reason: reason)
    }

    deinit {
        ProcessInfo.processInfo.endActivity(activity)
    }
}
