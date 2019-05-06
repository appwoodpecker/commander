//
//  ToolService.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolService: NSObject {
    
    private override init() {
        
    }
    
    private static let sharedInstance = ToolService.init()

    class func shared() -> ToolService {
        return sharedInstance
    }
    
    func loadTool(path: String) -> ToolSet? {
        let rootSet = ToolSet.init()
        rootSet.title = "root"
        rootSet.path = "/"
        rootSet.iconPath = nil
        traversePath(path: rootSet.path, parentSet: rootSet, workPath: path)
        return rootSet
    }
    
    func traversePath(path: String, parentSet: ToolSet?, workPath: String) {
        let filePath = workPath + path
        let fm = FileManager.default
        let filenames = try? fm.contentsOfDirectory(atPath: filePath)
        for name in filenames! {
            print(name)
        }
    }
}
