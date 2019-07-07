//
//  Note.swift
//  Notes
//
//  Created by Александр Степанов on 28/06/2019.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import UIKit

struct Note {
    enum Importance: String {
        case unimportant = "unimportant"
        case usual = "usual"
        case important = "important"
    }
    
    let uid: String
    let title: String
    let content: String
    let color: UIColor
    let importance: Importance
    let selfDestructionDate: Date?
    
    init(uid: String = UUID().uuidString,
         title: String, content: String,
         color: UIColor = .white,
         importance: Importance,
         selfDestructionDate: Date? = nil
        ) {
        self.uid = uid
        self.title = title
        self.content = content
        self.color = color
        self.importance = importance
        self.selfDestructionDate = selfDestructionDate
    }
}
