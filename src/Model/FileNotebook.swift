//
//  FileNotebook.swift
//  Notes
//
//  Created by Александр Степанов on 28/06/2019.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

class FileNotebook {
    private(set) var notes: [String : Note]
    private let path: URL
    
    init(notes: [String : Note] = [:]) {
        self.notes = notes
        path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        DDLogInfo("create FileNotebook")
    }
    
    public func add(_ note: Note) {
        if notes[note.uid] != nil {
            DDLogWarn("add note with existing uid: \(note.uid)")
        }
        
        notes[note.uid] = note
        DDLogInfo("add new note with uid: \(note.uid)")
    }
    
    public func remove(with uid: String) {
        if notes[uid] == nil {
            DDLogWarn("delete note with nonexisting uid: \(uid)")
        }
        
        notes[uid] = nil
        DDLogInfo("delete note with uid: \(uid)")
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
            DDLogError("can't write to file")
        }
        
        DDLogInfo("success write to file")
    }
    
    public func loadFromFile() {
        var dict: [[String: Any]] = []
        let filePath = path.appendingPathComponent("notes.json")
        
        do {
            let text = try String(contentsOf: filePath, encoding: .utf8)
            let data = text.data(using: .utf8)
            dict = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]]
        } catch {
            DDLogError("can't read from file")
        }
        
        for element in dict {
            self.add(Note.parse(json: element)!)
        }
        
        DDLogInfo("success read from file")
    }
}
