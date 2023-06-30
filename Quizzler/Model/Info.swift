//
//  Info.swift
//  Quizzler
//
//  Created by Yashraj jadhav on 12/06/23.
//

import SwiftUI

struct Info : Codable {
    
    var title : String
    var peopleAttended : Int
    var rules : [String]
    
    enum CodingKeys : CodingKey {
        case title
        case peopleAttended
        case rules
    }
    
}
