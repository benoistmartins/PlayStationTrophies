//
//  RedirectInterceptor.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 13/05/2026.
//

import Foundation

final class RedirectInterceptor: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}