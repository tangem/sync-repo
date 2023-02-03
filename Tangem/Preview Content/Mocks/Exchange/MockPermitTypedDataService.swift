//
//  MockPermitTypedDataService.swift
//  Tangem
//
//  Created by Sergey Balashov on 03.02.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import TangemExchange

struct MockPermitTypedDataService: PermitTypedDataService {
    func buildPermitCallData(for currency: Currency, parameters: PermitParameters) async throws -> String { "" }
}
