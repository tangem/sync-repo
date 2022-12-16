//
//  JSONEncodable.swift
//  Tangem
//
//  Created by Sergey Balashov on 16.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol JSONEncodable {
    func encodeToJSON() throws -> JSON
}

extension JSONEncodable where Self: Encodable {
    func encodeToJSON() throws -> JSON {
        let data = try JSONEncoder().encode(self)
        let json = try JSONDecoder().decode(JSON.self, from: data)

        return json
    }
}
