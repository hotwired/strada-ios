//
//  File.swift
//  
//
//  Created by Fernando Olivares on 17/08/21.
//

import Foundation

class PathLoader {
    func pathFor(name: String, fileType: String) -> String? {
        let bundle = Bundle(for: type(of: self))
        return bundle.path(forResource: name, ofType: fileType)
    }
}
