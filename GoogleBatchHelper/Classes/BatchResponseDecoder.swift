//
// Created by longkai on 31/12/2016.
// Copyright (c) 2016 xiaolongtongxue.com. All rights reserved.
//

import Foundation

fileprivate let crAscii: UInt8 = 13 /// `\r`
fileprivate let colonAscii: UInt8 = 58 /// `:`
fileprivate let slashAscii: UInt8 = 47 /// `/`
fileprivate let spaceAscii: UInt8 = 32 // ` `
fileprivate let newLineAscii: UInt8 = 10 /// `\n`
fileprivate let contentLen = "Content-Length"

fileprivate func buildKMPTable(_ pattern: [UInt8]) -> [Int] {
    let len = pattern.count
    if len < 2 {
        return [ -1]
    }
    var pos = 2
    var cnd = 0 // next character of the current candidate substring
    var table = [Int](repeating: 0, count: len)
    // the first few values are fixed but different from what the algorithm might suggest
    table[0] = -1
    table[1] = 0
    while pos < len {
        if pattern[pos - 1] == pattern[cnd] { // first case: the substring continues
            table[pos] = cnd + 1
            cnd += 1
            pos += 1
        } else if cnd > 0 { // second case: it doesn't, but we can fall back
            cnd = 0
        } else { // third case: we have run out of candidates.  Note cnd = 0
            table[pos] = 0
            pos += 1
        }
    }
    return table
}

fileprivate func indexOf(_ pattern: [UInt8], kmpTable: [Int], data: Data, offset: Int) -> Int {
    let patternLen = pattern.count
    if patternLen == 0 {
        return offset
    }
    var i = offset // data position
    var j = 0 // pattern position
    let sourceLen = data.count
    while i + j < sourceLen {
        if data[i + j] == pattern[j] { // match
            if j == patternLen - 1 { // j has reached the end
                return i
            }
            j += 1 // next p
        } else { // where mismatch
            if kmpTable[j] > -1 { // we can skip some chars
                i = i + j - kmpTable[j] // backtracking where suffix = prefix
                j = kmpTable[j] // start at where we fail
            } else { // the first char mismatch
                i = i + j + 1 // move to next s
                j = 0 // cannot skip any chars, so start again
            }
        }
    }
    return -1
}

/* fileprivate */ public func skipBoundary(_ boundary: [UInt8], kmpTable: [Int], data: Data, offset: Int) -> Int? {
    let idx = indexOf(boundary, kmpTable: kmpTable, data: data, offset: offset)
    if idx == -1 { /// not found or `EOF`
        return nil
    }
    // skip remaining `(--)?\r\n`
    var i = idx + boundary.count
    let len = data.count
    while i < len && data[i] != newLineAscii {
        i += 1
    }
    return i + 1
}

/* fileprivate */ public func readHeader(_ data: Data, offset: Int) -> (String, String, Int) {
    let len = data.count
    /// find first `:`
    var i = offset
    var key = ""
    var val = ""
    /// consider trying C's `sscanf()`
    while i < len {
        let byte = data[i]

        guard byte != newLineAscii else {
            return ("", "", i + 1)
        }

        if byte == colonAscii {
            key = String(bytes: data[offset ..< i], encoding: String.Encoding.utf8)!
            i += 1
            break
        }

        i += 1
    }
    /// trim ` `
    while i < len && data[i] == spaceAscii {
        i += 1
    }
    // find value
    let j = i
    while i < len {
        let byte = data[i]
        if byte == crAscii /* || byte == newLineAscii */ {
            val = String(bytes: data[j ..< i], encoding: String.Encoding.utf8)!
            i += 1
            break
        }
        i += 1
    }
    /// read full line `\n`
    while i < len {
        if data[i] == newLineAscii {
            return (key, val, i + 1)
        }
        i += 1
    }
    return (key, val, i)
}

/* fileprivate */ public func startLine(_ data: Data, start: Int, end: Int) -> (String, Int)? {
    guard start < end else {
        return nil
    }
    /// sth. like `HTTP/1.1 200 OK`
    let line = Data(data[start ..< end])
    return line.withUnsafeBytes { (bytes: UnsafePointer<Int8>) -> (String, Int)? in
        /// todo: let caller alloc these memory
        let httpPtr = UnsafeMutablePointer<CChar>.allocate(capacity: 16)
        let versionPtr = UnsafeMutablePointer<CChar>.allocate(capacity: 16)
        let statusPtr = UnsafeMutablePointer<CInt>.allocate(capacity: 1)

        defer {
            httpPtr.deallocate(capacity: 16)
            versionPtr.deallocate(capacity: 16)
            statusPtr.deallocate(capacity: 1)
        }

        let args = getVaList([httpPtr, versionPtr, statusPtr])
        guard vsscanf(bytes, "%[^/]/%s %d", args) == 3 else {
            return nil
        }
        return (String(cString: versionPtr), Int(statusPtr.pointee))
    }
}

// fileprivate func skipLine(_ data: Data, offset: Int) -> Int {
//    let len = data.count
//    var i = offset
//    while i < len && data[i] != newLineAscii {
//        i += 1
//    }
//    return i + 1
// }

/// Decode the batch response, the result is exactly like the URLSession response,
/// but encapsulate in a array.
public struct BatchResponseDecoder {
    public let data: [Data?]
    public let resp: [HTTPURLResponse?]

    public init?(data: Data, boundary: String) {
        var _data = [Data?]()
        var resp = [HTTPURLResponse?]()

        // to bytes slice
        let boundaryPattern = "--\(boundary)".utf8.map { UInt8($0) }
        let kmpTable = buildKMPTable(boundaryPattern)
        let len = data.count
        let maxLineDelimiterCount = 2

        var offset = 0
        while let idx = skipBoundary(boundaryPattern, kmpTable: kmpTable, data: data, offset: offset), idx < len {
            offset = idx
            var headers = [String: String]()
            var statusCode: Int?
            var httpVersion: String?
            var bodyLen: Int?
            /// parse headers
            var lineDelimiterCount = 0
            while lineDelimiterCount < maxLineDelimiterCount && offset < len {
                let (key, val, newOffset) = readHeader(data, offset: offset)
                if key.isEmpty {
                    // if no header found, it must be merely a newline or HTTP start line
                    if let status = startLine(data, start: offset, end: newOffset) {
                        httpVersion = status.0
                        statusCode = status.1
                    } else {
                        lineDelimiterCount += 1
                    }
                } else {
                    headers[key] = val
                    if key.caseInsensitiveCompare(contentLen) == ComparisonResult.orderedSame {
                        bodyLen = Int(val)
                    }
                }
                offset = newOffset
            }
            // parse body
            guard
                let bodyLength = bodyLen,
                lineDelimiterCount == maxLineDelimiterCount
            else {
                print("debug", "malformed data")
                return nil // malformed data
            }
            /// exit early if `EOF`
            guard offset + bodyLength < len else {
                break
            }

            let body = data[offset ..< offset + bodyLength]
            _data.append(Data(body))
            offset += bodyLength

            // gather data
            if let statusCode = statusCode {
                let _resp = HTTPURLResponse(
                    // just a reminder that it's from a batch url, not the real one
                    url: URL(string: "https://foo.bar/batch.txt")!,
                    statusCode: statusCode,
                    httpVersion: httpVersion,
                    headerFields: headers)
                resp.append(_resp)
            } else {
                resp.append(nil)
            }
        }

        self.data = _data
        self.resp = resp
    }
}

/// e.g. from `multipart/mixed; boundary=batch__8V5rCfdLyo_AA7YPKoEWIo` to `batch__8V5rCfdLyo_AA7YPKoEWIo`
public func resolveBoundary(_ str: String) -> String? {
    let sep = "boundary="
    if let pointer = strstr(str, sep) {
        return String(cString: pointer + sep.utf8.count)
    }
    return nil
}
