//
//  ToolItem.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolItem: NSObject {
    
    var title: String!
    var scriptFile: String!
    var path: String!
    
    func scriptPath() -> String {
        return path.appendingPathComponent(scriptFile)
    }
    
    func iconPath() -> String {
        return path.appendingPathComponent("icon.png")
    }
    
}
