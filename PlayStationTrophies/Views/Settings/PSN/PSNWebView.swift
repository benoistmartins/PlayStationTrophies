//
//  PSNWebView..swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import SwiftUI
import WebKit

struct PSNWebView: UIViewRepresentable {
    let onNpssoReceived: (String) -> Void
    let onError: (String) -> Void
    @Binding var showGetToken: Bool

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        webView.load(URLRequest(url: URL(string: "https://www.playstation.com/en-us/")!))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if showGetToken {
            uiView.load(URLRequest(url: URL(string: "https://ca.account.sony.com/api/v1/ssocookie")!))
            DispatchQueue.main.async {
                showGetToken = false
            }
        }
    }

    func makeCoordinator() -> PSNWebViewCoordinator {
        PSNWebViewCoordinator(onNpssoReceived: onNpssoReceived, onError: onError)
    }
}
