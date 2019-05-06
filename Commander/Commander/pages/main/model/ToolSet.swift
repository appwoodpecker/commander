//
//  ToolSet.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolSet: NSObject {
    
    var title: String!
    var path: String!
    var iconPath: String?
    var children: [ToolItem]?
    
    func isTop() -> Bool {
        return self.title == "root"
    }
    
}
