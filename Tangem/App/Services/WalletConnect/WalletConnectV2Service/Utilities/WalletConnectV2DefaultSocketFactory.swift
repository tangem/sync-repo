//
//  DefaultWCSocketFactory.swift
//  Tangem
//
//  Created by Andrew Son on 22/12/22.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import WalletConnectSwiftV2

class WalletConnectV2DefaultSocketFactory: WebSocketFactory {
    /// `create(with url: URL)` is called from internal entities of WalletConnectSwiftV2 lib
    /// but we also need to have access to `WebSocket` to be able to get current connection status
    /// otherwise continuation issues may occur during new session connection
    private(set) var lastCreatetSocket: WebSocket?

    func create(with url: URL) -> WebSocketConnecting {
        let socket = WebSocket(url: url)
        lastCreatetSocket = socket
        return socket
    }
}

extension WebSocket: WebSocketConnecting {}
