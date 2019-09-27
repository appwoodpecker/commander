//
//  ToolItem.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolItem: NSObject {
    
    var title: String!
    var scriptFile: String?
    var appId: String?
    var toolset: ToolSet!
    
    func fileName() -> String {
        return self.title + ".bundle"
    }
    
    func path() -> String {
        return self.toolset.absolutePath().appendingPathComponent(fileName())
    }
    
    func scriptPath() -> String {
        return path().appendingPathComponent(scriptFile!)
    }
    
    func iconPath() -> String {
        return path().appendingPathComponent("icon.png")
    }
    
    func isApp() -> Bool {
        return appId != nil
    }
    
}
