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
    
    func loadTool() -> ToolSet {
        let path = Config.shared().workPath()
        let rootSet = ToolSet.init()
        rootSet.title = "root"
        rootSet.path = "/"
        rootSet.children = []
        traversePath(path: rootSet.path, parentSet: rootSet, workPath: path)
        return rootSet
    }
    
    func traversePath(path: String, parentSet: ToolSet, workPath: String) {
        let filePath = workPath.appendingPathComponent(path)
        let fm = FileManager.default
        let filenames = try? fm.contentsOfDirectory(atPath: filePath)
        for name in filenames! {
            if name.hasPrefix(".") {
                continue
            }
            let itemPath = filePath.appendingPathComponent(name)
            let attributes = try? fm .attributesOfItem(atPath: itemPath)
            if attributes == nil {
                continue;
            }
             let type: String = attributes![FileAttributeKey.type] as! String
            if(type == FileAttributeType.typeDirectory.rawValue) {
                if name.hasSuffix("bundle") {
                    ///item
                    var title: String?
                    var scriptFile: String?
                    var path: String?
                    //title
                    let manifestPath = itemPath.appendingPathComponent("manifest.json")
                    let manifestURL = URL.init(fileURLWithPath: manifestPath)
                    let data = try? Data.init(contentsOf: manifestURL)
                    if let data1 = data {
                        let configData = try? JSONSerialization.jsonObject(with: data1, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [String:String]
                        title = configData?["title"]
                        if title == nil {
                            title = name.replacingOccurrences(of: ".bundle", with: "")
                        }
                    }
                    //script
                    let types = Config.shared().supportScriptTypes()
                    var scriptFileName :String?
                    for type in types {
                        let fileName = "main." + type
                        let filePath = itemPath.appendingPathComponent(fileName)
                        let exists = fm.fileExists(atPath: filePath)
                        if exists {
                            scriptFileName = fileName
                            break
                        }
                    }
                    if scriptFileName != nil {
                        scriptFile = scriptFileName
                    }
                    //path
                    path = parentSet.path.appendingPathComponent(name)
                    if title != nil && scriptFileName != nil && path != nil {
                        let toolItem = ToolItem.init()
                        toolItem.title = title
                        toolItem.scriptFile = scriptFile
                        toolItem.path = path
                        parentSet.children!.append(toolItem)
                    }
                }else {
                    //set
                    var title: String?
                    var path: String?
                    //title
                    title = name
                    //path
                    path = parentSet.path.appendingPathComponent(name)
                    if title != nil && path != nil {
                        let set = ToolSet.init()
                        set.title = title
                        set.path = path;
                        set.children = []
                        parentSet.children.append(set)
                        //continue traverse
                        traversePath(path: set.path, parentSet: set, workPath: workPath)
                    }
                }
            }
        }
    }
}
