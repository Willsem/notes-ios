//
//  FileNotebook.swift
//  Notes
//
//  Created by Александр Степанов on 28/06/2019.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import UIKit

class FileNotebook {
    private(set) var notes: [Note]
    private let path: URL
    
    init(notes: [Note] = []) {
        self.notes = notes
        path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    public func add(_ note: Note) {
        for element in notes {
            if element.uid == note.uid {
                return
            }
        }
        notes.append(note)
    }
    
    public func remove(with uid: String) {
        var ind: Int = -1
        for (index, element) in notes.enumerated() {
            if uid == element.uid {
                ind = index
                break
            }
        }
        
        if ind == -1 {
            return
        }
        notes.remove(at: ind)
    }
    
    public func saveToFile() {
        var all: [[String: Any]] = []
        for element in notes {
            let dict: [String: Any] = element.json
            all.append(dict)
        }
        
        let filePath = path.appendingPathComponent("notes.json").path
        let fileManager = FileManager()
        do {
            let data = try JSONSerialization.data(withJSONObject: all, options: [])
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        } catch {
            print("can't write")
        }
    }
    
    public func loadFromFile() {
        var dict: [[String: Any]] = []
        let filePath = path.appendingPathComponent("notes.json")
        
        do {
            let text = try String(contentsOf: filePath, encoding: .utf8)
            let data = text.data(using: .utf8)
            dict = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]]
        } catch {
            print("can't read")
        }
        
        for element in dict {
            self.add(Note.parse(json: element)!)
        }
    }
}
