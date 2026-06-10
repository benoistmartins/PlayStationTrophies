//
//  PSNJWTDecoder.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 13/05/2026.
//

import Foundation

struct PSNJWTDecoder {
    static func extractAccountId(from jwt: String) -> String? {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accountId = json["account_id"] as? String else {
            return nil
        }
        return accountId
    }
}