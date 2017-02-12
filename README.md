# GoogleBatchHelper

A simple [Google batch API][] request/response encode/decode helper for both iOS and macOS written in Swift 3.

[![CI Status](http://img.shields.io/travis/longkai/GoogleBatchHelper.svg?style=flat)](https://travis-ci.org/longkai/GoogleBatchHelper)
[![Version](https://img.shields.io/cocoapods/v/GoogleBatchHelper.svg?style=flat)](http://cocoapods.org/pods/GoogleBatchHelper)
[![License](https://img.shields.io/cocoapods/l/GoogleBatchHelper.svg?style=flat)](http://cocoapods.org/pods/GoogleBatchHelper)
[![Platform](https://img.shields.io/cocoapods/p/GoogleBatchHelper.svg?style=flat)](http://cocoapods.org/pods/GoogleBatchHelper)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
/// - ids: support your requested entity id array
func encodeBatchRequest(_ ids: [String]) {
    let boundary = "\(Date().timeIntervalSince1970)"
    var req = URLRequest(url: URL(string: "https://www.googleapis.com/batch")!)
    req.addValue("multipart/mixed; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    req.httpMethod = "POST"

    var reqs = [URLRequest]()
    for idx in ids.indices {
        let req = URLRequest(url: URL(string: "/gmail/v1/users/me/threads/\(ids[idx])?fields=id,historyId,messages(id,threadId,labelIds,internalDate,historyId,payload(headers))")!)
        reqs.append(req)
    }
    let encoder = BatchRequestEncoder(reqs, contentIDs: [String](ids), boundary: boundary)
    req.httpBody = encoder.body

    // perform the requst...
}

/// this is exactly like you do in `func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?)` in a array way.
func decodeBatchResponse(_ respBoundary: String, _ data: Data) {
    guard let batch = BatchResponseDecoder(data: data, boundary: respBoundary) else {
        fatalError("fail")
    }
    // a lot work to do
    for idx in batch.resp.indices {
        if let data = batch.data[idx],
            let resp = batch.resp[idx],
            resp.statusCode == 200 {

            // do your job...
        } else {
            let str = String(data: batch.data[idx]!, encoding: String.Encoding.utf8)
            // handle error
        }
    }
}
```

## Requirements

- iOS 8.0+
- macOS 10.9+

## Installation

GoogleBatchHelper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GoogleBatchHelper"
```

## Author

longkai, im.longkai@gmail.com

## License

GoogleBatchHelper is available under the MIT license. See the LICENSE file for more info.


[Google batch API]: https://cloud.google.com/storage/docs/json_api/v1/how-tos/batch
