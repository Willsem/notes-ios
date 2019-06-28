//
//  NoteExtensions.swift
//  Notes
//
//  Created by Александр Степанов on 28/06/2019.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import UIKit

extension Note {
    static func parse(json: [String: Any]) -> Note? {
        let importance: Importance
        switch json["importance"] {
        case nil: importance = .usual
        case let imp: importance = Importance(rawValue: imp as! String)!
        }
        
        var color: UIColor = .white
        if json["color"] != nil {
            let str = json["color"] as! String
            
            let r: Int = Note.fromHex(str[1] + str[2])
            let g: Int = Note.fromHex(str[3] + str[4])
            let b: Int = Note.fromHex(str[5] + str[6])
            let a: Int = Note.fromHex(str[7] + str[8])
            
            color = UIColor(red: CGFloat(r) / 255,
                            green: CGFloat(g) / 255,
                            blue: CGFloat(b) / 255,
                            alpha: CGFloat(a) / 255)
        }
        
        var selfDestructionDate: Date? = nil
        if json["selfDestructionDate"] != nil {
            let format = ISO8601DateFormatter()
            selfDestructionDate = format.date(from: json["selfDestructionDate"] as! String)
        }
        
        let note: Note? = Note(uid: json["uid"] as! String,
                               title: json["title"] as! String,
                               content: json["content"] as! String,
                               color: color,
                               importance: importance,
                               selfDestructionDate: selfDestructionDate)
        
        return note
    }
    
    var json: [String: Any] {
        var result: [String: Any] = [:]
        result["uid"] = self.uid
        result["title"] = self.title
        result["content"] = self.content
        
        if self.color != .white {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            
            self.color.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            result["color"] = "#" + Note.toHex(Int(255 * r))
                + Note.toHex(Int(255 * g))
                + Note.toHex(Int(255 * b))
                + Note.toHex(Int(255 * a))
        }
        
        switch importance {
        case .important, .unimportant: result["importance"] = importance.rawValue
        case .usual: break
        }
        
        if selfDestructionDate != nil {
            let format = ISO8601DateFormatter()
            result["selfDestructionDate"] = format.string(from: selfDestructionDate!)
        }
        
        return result
    }
    
    /*
     * Функция перевода числа из 16сс в 10сс в диапазоне 0...255 (00...ff)
     */
    private static func fromHex(_ number: String) -> Int {
        let get = {(_ char: String) -> Int in
            switch char {
            case "a": return 10
            case "b": return 11
            case "c": return 12
            case "d": return 13
            case "e": return 14
            case "f": return 15
            case let a: return Int(a)!
            }
        }
        
        let ln = get(number[0])
        let rn = get(number[1])
        return ln * 16 + rn
    }
    
    /*
     * Функция перевода числа в дипазоне 0...255 в 16сс (00...ff)
     */
    private static func toHex(_ number: Int) -> String {
        guard number >= 0 && number <= 255 else {
            return "" // Знаю, что лучше кинуть throw
        }
        
        if number == 0 {
            return "00"
        }
        
        var n = number
        var hex = ""
        
        while n != 0 {
            switch n % 16 {
            case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9: hex += String(n % 16)
            case 10: hex += "a"
            case 11: hex += "b"
            case 12: hex += "c"
            case 13: hex += "d"
            case 14: hex += "e"
            case 15: hex += "f"
            default: break
            }
            n /= 16
        }
        
        if number < 16 {
            hex += "0"
        }
        
        return String(hex.reversed())
    }
}

/*
 * Расширение для String, взятие по индексу
 */
extension String {
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
