//
//  SendRoutable.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

protocol SendRoutable: AnyObject {
    func openQRScanner(with codeBinding: Binding<String>)
}
