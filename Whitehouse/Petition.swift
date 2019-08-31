//
//  Petition.swift
//  Whitehouse
//
//  Created by José Eduardo Pedron Tessele on 30/08/19.
//  Copyright © 2019 José P Tessele. All rights reserved.
//

import Foundation


struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
