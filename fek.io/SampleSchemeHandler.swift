//
//  SampleSchemeHandler.swift
//  fek.io
//
//  Created by David Fekke on 6/30/20.
//  Copyright © 2020 David Fekke L.L.C. All rights reserved.
//

import UIKit
import WebKit

class SampleSchemeHandler: NSObject, WKURLSchemeHandler {
    
    static let scheme = "sample"
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        DispatchQueue.global().async {
            if let url = urlSchemeTask.request.url, url.scheme == SampleSchemeHandler.self.scheme {
                let mime = self.mimeType(for: url)
                let urlResponse = URLResponse(url: url, mimeType: mime, expectedContentLength: -1, textEncodingName: nil)
                urlSchemeTask.didReceive(urlResponse)
                if let data = FileManager.default.contents(atPath: url.path) {
                    urlSchemeTask.didReceive(data)
                    urlSchemeTask.didFinish()
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        let error = SampleError(title: "Sample Error", description: "This is an example error", code: 5001)
        
        urlSchemeTask.didFailWithError(error)
    }
    
    func mimeType(for url: URL) -> String {
        switch (url.absoluteString as NSString).pathExtension.lowercased() {
            case "3gp":
                return "video/3gpp"
            case "mp3":
                return "audio/mpeg"
            case "mp4":
                return "video/mp4"
            case "m4a":
                return "audio/mp4"
            case "m4v":
                return "video/m4v"
            case "wav":
                return "audio/wav"
            case "caf":
                return "audio/x-caf"
            case "aac":
                return "audio/aac"
            case "adts":
                return "audio/mpeg"
            case "aif":
                return "audio/wav"
            case "aiff":
                return "audio/wav"
            case "aifc":
                return "audio/aiff"
            case "au":
                return "audio/basic"
            case "snd":
                return "audio/basic"
            case "sd2":
                return "application/spss"
            case "mov":
                return "video/quicktime"
            case "tiff", "tif":
                return "image/tiff"
            case "jpeg", "jpg":
                return "image/jpeg"
            case "png":
                return "image/png"
            case "gif":
                return "image/gif"
            case "doc":
                return "application/msword"
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            case "csv":
                return "text/csv"
            case "txt":
                return "text/plain"
            case "html", "htm":
                return "text/html"
            case "rtf":
                return "application/rtf"
            case "xls":
                return "application/vnd.ms-excel"
            case "xlsx":
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            case "pdf":
                return "application/pdf"
            case "snote":
                return "text/html"
            default:
                return "application/octet-stream"
        }
        
    }
}
