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
    private(set) var notes: [String : Note]
    private let path: URL
    
    init(notes: [String : Note] = [:]) {
        self.notes = notes
        path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    public func add(_ note: Note) {
        notes[note.uid] = note
    }
    
    public func remove(with uid: String) {
        notes[uid] = nil
    }
    
    public func saveToFile() {
        var all: [[String: Any]] = []
        for (_, element) in notes {
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
