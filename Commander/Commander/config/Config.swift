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
    
    func setupEnvt() {
        let path = rootPath()
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: path)
        if !exists {
            try? fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            if let defaultPath = Bundle.main.path(forResource: "menubar", ofType: nil) {
                try? fm.copyItem(atPath: defaultPath, toPath: workPath())
            }
        }
    }
    
    func rootPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = paths.first
        let rootPath = docPath?.appendingPathComponent("Commander")
        return rootPath!
    }
    
    func workPath() -> String {
        return rootPath().appendingPathComponent("menubar")
    }
    
    func getAppList() -> [String] {
        return ["QRApp"]
    }
    
    func defaultPackage() -> String {
        return "Commander"
    }
    
}
