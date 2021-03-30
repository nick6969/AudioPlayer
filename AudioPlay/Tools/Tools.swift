//
//  Tools.swift
//  AudioPlay
//
//  Created by Nick on 3/30/21.
//

import Foundation
import AVFoundation

private let DOMAIN: String = "https://"
let TEST_M3U8_URL: URL = URL(string: DOMAIN + "/playlist.m3u8")!

func print<T>(msg message: T, file: String = #file, method: String = #function, line: Int = #line) {
    print("AP-\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
}

extension TimeInterval {
    var cmTime: CMTime {
        return CMTimeMakeWithSeconds(self, preferredTimescale: 600)
    }
}
extension CMTime {
    var timeInterval: TimeInterval {
        return CMTimeGetSeconds(self)
    }
}

enum PlayerKeyPath: String, CaseIterable {
    case status = "status"
    case itemStatus = "currentItem.status"
    case timeControlStatus = "timeControlStatus"
    case itemDuration = "currentItem.duration"
    case rate = "rate"
}
