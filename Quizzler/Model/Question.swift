//
//  Question.swift
//  Quizzler
//
//  Created by Yashraj jadhav on 12/06/23.
//

import SwiftUI

struct Question : Identifiable , Codable {
    var id : UUID = .init()
    var answer : String
    var options : [String]
    var question : String
    
   
    
    // For UI State Updated
    
    var tappedAnswer : String = ""
    
    enum CodingKeys : CodingKey {
        case question
        case options
        case answer
    }
    
}
