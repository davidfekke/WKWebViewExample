//
//  ViewController.swift
//  fek.io
//
//  Created by David Fekke on 6/30/20.
//  Copyright © 2020 David Fekke L.L.C. All rights reserved.
//
// Inspired by Zafar Ivaev's https://medium.com/better-programming/create-a-wkwebview-programmatically-in-swift-5-fc08c8ad8708

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.setURLSchemeHandler(SampleSchemeHandler(), forURLScheme: SampleSchemeHandler.self.scheme)
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    let forwardBarItem = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(forwardAction))
    let backBarItem = UIBarButtonItem(title: "Backward", style: .plain, target: self, action: #selector(backAction))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        setupNavItem()
        if let myURL = URL(string: "https://www.fek.io") {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }

    func layoutUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
    }

    func setupNavItem() {
        self.navigationItem.leftBarButtonItem = backBarItem
        self.navigationItem.rightBarButtonItem = forwardBarItem
    }
        
    func setupNavBar() {
        self.navigationController?.navigationBar.barTintColor = .systemBlue
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func cleanup() {
            // remove all the webview instances
        let userController = self.webView.configuration.userContentController
        userController.removeAllUserScripts()
          
        self.webView.uiDelegate = nil
        self.webView.navigationDelegate = nil
        self.webView.removeFromSuperview()
            
        //let app = UIApplication.shared.delegate  //(AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // remove store for a pending save record
        //let defaults = UserDefaults.standard
        //defaults.synchronize()
        
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Navigation Delegate methods
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.webView(webView, didStartProvisionalNavigation: navigation)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        // set a timestamp
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        let response = navigationResponse.response as! HTTPURLResponse
        if let headers = response.allHeaderFields as NSDictionary? as? [String:String],
            let responseUrl = response.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: responseUrl)
             
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Some authentication services may require NTLM or Kerberos
        let isNtlmAuthEnabled = false
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        
        if isNtlmAuthEnabled {
            print("didReceiveAuthenticationChallenge NTLM enabled")
            if authenticationMethod == NSURLAuthenticationMethodNegotiate {
                print("authenticationMethod NSURLAuthenticationMethodNegotiate (kerberos)")
                //Reject the request which should result in a follow up NTLM challenge
                completionHandler(.rejectProtectionSpace, nil)
            } else if authenticationMethod == NSURLAuthenticationMethodNTLM {
                print("authenticationMethod NSURLAuthenticationMethodNTLM")
                //respond with credentials, replace URLCredential() with actual creds
                challenge.sender?.use(URLCredential(), for: challenge)
            }
        } else {
            print("didReceiveAuthenticationChallenge NTLM disabled")
            let lastCredentialUsed = URLCredential()
            completionHandler(.performDefaultHandling, lastCredentialUsed)
        }
    }
    
    func requiresCookie(_ navigationAction: WKNavigationAction) -> Bool {
        return true
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Load JavaScript here
        // [webView evaluateJavaScript:jpmcJS completionHandler:^(id result, NSError *error) {
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView failed because \(error.localizedDescription)")
    }
    
    // MARK: - Obj-C functions for navigation
    
    @objc func forwardAction() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
        
    @objc func backAction() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    
}

