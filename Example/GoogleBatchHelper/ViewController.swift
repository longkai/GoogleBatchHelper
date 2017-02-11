//
//  ViewController.swift
//  GoogleBatchHelper
//
//  Created by longkai on 02/12/2017.
//  Copyright (c) 2017 longkai. All rights reserved.
//

import UIKit
import GoogleBatchHelper

/// Sample usage for the library
class ViewController: UIViewController {

    /// - ids: support your requested entity id array
    func encodeBatchRequest(_ ids: [String]) {
        let boundary = "\(Date().timeIntervalSince1970)"
        var req = URLRequest(url: URL(string: "")!)
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

    func decodeBatchRequest() {
        print(#function)
    }
}
