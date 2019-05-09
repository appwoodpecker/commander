//
//  ToolSet.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolSet: NSObject {
    
    var title: String!
    var path: String!
    var children: [Any]!
    var parentSet: ToolSet?
    
    func isRoot() -> Bool {
        return self.path == "/"
    }
    
    func iconPath() -> String {
        return absolutePath().appendingPathComponent("icon.png")
    }
    
    func absolutePath() -> String {
        return Config.shared().workPath().appendingPathComponent(self.path)
    }
    
    func absoluteURL() -> URL {
        let url = URL.init(fileURLWithPath: absolutePath())
        return url
    }
    
    func configPath() -> String {
        return absolutePath().appendingPathComponent("config.json")
    }
    
    func getSortList() -> [String] {
        var sortList :[String]?
        let configPath = self.configPath()
        if let data = NSData.init(contentsOfFile: configPath) {
            if let jsonObj = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) {
                let configData = jsonObj as! [String : Any]
                sortList = (configData["sort"] as! [String])
            }
        }
        if sortList == nil {
            sortList = [String].init()
        }
        return sortList!
    }
    
}
