//
// Created by longkai on 31/12/2016.
// Copyright (c) 2016 xiaolongtongxue.com. All rights reserved.
//

import Foundation

fileprivate let contentLength = "Content-Length"

public struct BatchRequestEncoder {
    /// Batch HTTP request entity
    public let body: Data

    public init(_ requests: [URLRequest], contentIDs: [String], boundary: String) {
        guard requests.count == contentIDs.count else {
            preconditionFailure()
        }
        var body = Data(capacity: 1024 << 2) // 4k buffer
        var line = "--\(boundary)"
        body.append(line, count: line.utf8.count)
        for idx in requests.indices {
            let req: URLRequest = requests[idx]
            line = "\r\nContent-Type: application/http"
            body.append(line, count: line.utf8.count)
            line = "\r\nContent-ID: <\(idx):\(contentIDs[idx])>\r\n"
            body.append(line, count: line.utf8.count)

            guard let url = req.url else {
                preconditionFailure()
            }

            let uri = url.path.trimmingCharacters(in: CharacterSet.whitespaces)
            let path = uri == "" ? "/" : uri // normalize path

            let method = req.httpMethod?.uppercased() ?? "GET" /// default to `GET`
            let startLine = "\r\n\(method) \(path)"
            body.append(startLine, count: startLine.utf8.count)

            /// no `HTTP/x.x` since we're wrap in a batched request
            if method == "GET" || method == "HEAD" || method == "DELETE", let query = url.query {
                let tail = "?\(query)"
                body.append(tail, count: tail.utf8.count)
            }

            var hasContentLen = false // if client has issued the `Content-Length` header field

            // headers
            for (k, v) in req.allHTTPHeaderFields ?? [:] {
                if k.caseInsensitiveCompare(contentLength) == .orderedSame {
                    hasContentLen = true
                }
                let headerLine = "\r\n\(k): \(v)"
                body.append(headerLine, count: headerLine.utf8.count)
            }
            // body, if any
            if method == "POST" || method == "PUT", let httpBody = req.httpBody {
                if !hasContentLen {
                    let contentLength = "\r\nContent-Length: \(httpBody.count)"
                    body.append(contentLength, count: contentLength.utf8.count)
                }
                body.append("\r\n\r\n", count: 4)
                body.append(httpBody)
            }
            // ends line
            line = "\r\n\r\n--\(boundary)"
            body.append(line, count: line.utf8.count)
        }
        body.append("--", count: 2) // finish indicator

        self.body = body
    }
}
