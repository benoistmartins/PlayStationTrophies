//
//  PSNNpssoExtractor.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation
import WebKit

final class PSNNpssoExtractor: NSObject {
    private let onSuccess: (String) -> Void
    private let onError: (String) -> Void
    
    init(onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    func handleNavigation(in webView: WKWebView) {
        guard let url = webView.url else { return }
        
        if url.absoluteString.contains("ssocookie") {
            webView.evaluateJavaScript("document.body.innerText") { [weak self] result, error in
                guard let self else { return }
                
                if let error {
                    self.onError(error.localizedDescription)
                    return
                }
                
                guard let text = result as? String,
                      let data = text.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let npsso = json["npsso"] as? String else {
                    self.onError(PSNAuthError.npssoNotFound.localizedDescription)
                    return
                }
                self.onSuccess(npsso)
            }
        }
    }
}
