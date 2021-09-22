//
//  File.swift
//  
//
//  Created by Fernando Olivares on 17/08/21.
//

import Foundation

class PathLoader {
    func pathFor(name: String, fileType: String, directory: String = "JavaScript") -> String? {
        return Bundle.module.path(forResource: name, ofType: fileType, inDirectory: directory)
    }
}
