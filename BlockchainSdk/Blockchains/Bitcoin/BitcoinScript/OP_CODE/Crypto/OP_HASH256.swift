//
//  OP_HASH256.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/08/09.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

// The input is hashed two times with SHA-256.
public struct OpHash256: OpCodeProtocol {
    public var value: UInt8 { return 0xaa }
    public var name: String { return "OP_HASH256" }
}
