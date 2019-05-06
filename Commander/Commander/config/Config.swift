//
//  Config.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class Config: NSObject {
    
    private override init() {
        
    }
    
    private static let sharedInstance = Config.init()
    
    class func shared() -> Config {
        return sharedInstance
    }
    
    func supportScriptTypes() -> [String] {
        return ["sh","py"]
    }
    
    func selectScriptTypes() -> [String] {
        let scriptTypes = ["Shell (.sh)","Python (.py)"]
        return scriptTypes
    }
    
    
    
    func exeForScriptFile(_ scriptPath: String) -> String? {
        var exe: String?
        if scriptPath.hasSuffix(".sh") {
            exe = "/bin/bash"
        }else if scriptPath.hasSuffix(".py") {
            exe = "/usr/bin/python"
        }
        return exe
    }
    
    func workPath() -> String {
        return"/Users/zhangxiaogang/Documents/GitHub/Commander/workspace"
    }
    
}
