//
//  PSNWebViewCoordinator.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import WebKit

final class PSNWebViewCoordinator: NSObject, WKNavigationDelegate {
    private let onNpssoReceived: (String) -> Void
    private let onError: (String) -> Void
    private let extractor: PSNNpssoExtractor

    init(onNpssoReceived: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        self.onNpssoReceived = onNpssoReceived
        self.onError = onError
        self.extractor = PSNNpssoExtractor(onSuccess: onNpssoReceived, onError: onError)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NotificationCenter.default.post(name: .psnWebViewDidFinishLoad, object: nil)
        extractor.handleNavigation(in: webView)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        .allow
    }
}

extension Notification.Name {
    static let psnWebViewDidFinishLoad = Notification.Name("psnWebViewDidFinishLoad")
}