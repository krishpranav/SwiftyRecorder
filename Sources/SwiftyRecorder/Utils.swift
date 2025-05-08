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
    public static var hasPermissions: Bool {
        get async {
            do {
                _ = try await SCSharableContent.current
                return true
            } catch {
                return false
            }
        }
    }
}

extension CMSampleBuffer {
    public func adjustTime(by offset: CMTime) -> CMSampleBuffer? {
        guard self.formatDescription != nil, offset.value > 0 else {
            return nil
        }

        do {
            var timingInfo = try self.sampleTimingInfos()
        } catch {
            return nil
        }
    }
}
