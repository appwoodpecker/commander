//
//  ToolService.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/6.
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
                    //tool or app
                    var title: String?
                    var scriptFile: String?
                    var appId: String?
                    
                    let appFilename = "app.json"
                    let appPath = itemPath.appendingPathComponent(appFilename)
                    if fm.fileExists(atPath: appPath) {
                        do {
                            let infoText = try String.init(contentsOfFile: appPath)
                            if let appInfo = infoText.jsonObject() {
                                appId = appInfo["id"] as? String
                            }
                        }catch {
                            
                        }
                    }
                    //title
                    title = name.replacingOccurrences(of: ".bundle", with: "")
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
                    if title != nil && (scriptFileName != nil || appId != nil) {
                        let toolItem = ToolItem.init()
                        toolItem.title = title
                        toolItem.scriptFile = scriptFile
                        toolItem.appId = appId
                        parentSet.children!.append(toolItem)
                        toolItem.toolset = parentSet
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
                        set.parentSet = parentSet
                        //continue traverse
                        traversePath(path: set.path, parentSet: set, workPath: workPath)
                    }
                }
            }
        }
        ///sort children
        let children = parentSet.children
        let sortList = parentSet.getSortList()
        var sortedChildren = [Any].init()
        for name in sortList {
            var targetItem: Any?
            for item in children! {
                if item is ToolItem {
                    let toolItem = item as! ToolItem
                    if toolItem.fileName() == name {
                        targetItem = item
                        break
                    }
                }else if item is ToolSet {
                    let toolSet = item as! ToolSet
                    if toolSet.title == name {
                        targetItem = item
                        break;
                    }
                }
            }
            if targetItem != nil {
                sortedChildren.append(targetItem!)
            }
        }
        //items that not in sort list
        var leftItems = [Any].init()
        for item in children! {
            var exists = false
            exists = sortedChildren.contains(where: { (aItem) -> Bool in
                if item is ToolItem && aItem is ToolItem {
                    let toolItem = item as! ToolItem
                    let aToolItem = aItem as! ToolItem
                    return (toolItem == aToolItem)
                }else if item is ToolSet && aItem is ToolSet {
                    let toolItem = item as! ToolSet
                    let aToolItem = aItem as! ToolSet
                    return (toolItem == aToolItem)
                }else {
                    return false
                }
            })
            if !exists {
                leftItems.append(item)
            }
        }
        //sort left items
        leftItems.sort { (item1, item2) -> Bool in
            var title1: String?
            var title2: String?
            if item1 is ToolItem {
                let toolItem = item1 as! ToolItem
                title1 = toolItem.title
            }else if item1 is ToolSet {
                let toolSet = item1 as! ToolSet
                title1 = toolSet.title
            }
            
            if item2 is ToolItem {
                let toolItem = item2 as! ToolItem
                title2 = toolItem.title
            }else if item2 is ToolSet {
                let toolSet = item2 as! ToolSet
                title2 = toolSet.title
            }
            if title1 == nil || title2 == nil {
                return false
            }else {
                let result = title1!.compare(title2!)
                if result == ComparisonResult.orderedDescending {
                    return false
                }else {
                    return true
                }
            }
        }
        //append left items
        sortedChildren.append(contentsOf: leftItems)
        parentSet.children = sortedChildren
    }
    
    //add tool
    func doAddTool(title: String, scriptType:String, scriptText: String, iconURL:URL?, parent: ToolSet) -> ToolItem? {
        let groupPath = parent.absolutePath()
        let groupURL = URL.init(fileURLWithPath: groupPath)
        
        ///everything is okay, now let's create it
        //1.tool bundle
        let bundleName = title + ".bundle"
        let bundleURL = groupURL.appendingPathComponent(bundleName)
        let fm = FileManager.default
        try? fm.createDirectory(at: bundleURL, withIntermediateDirectories: true, attributes: nil)
        //2.save code
        let scriptName = "main." + scriptType
        let scriptURL = bundleURL.appendingPathComponent(scriptName)
        let scriptPath = scriptURL.path
        let scriptData = scriptText.data(using: String.Encoding.utf8)
        let result = fm.createFile(atPath: scriptPath, contents: scriptData, attributes: nil)
        if !result {
            return nil;
        }
        //3.icon
        if let iconFileURL = iconURL {
            let targetURL = bundleURL.appendingPathComponent("icon.png")
            try? fm.copyItem(at: iconFileURL, to: targetURL)
        }
        let toolItem = ToolItem.init()
        toolItem.title = title
        toolItem.scriptFile = scriptName
        toolItem.toolset = parent
        parent.children.append(toolItem)
        return toolItem
    }
    
    //edit tool
    func doEditTool(title: String, scriptType:String, scriptText: String, iconURL:URL?, toolItem: ToolItem) {
        let setURL = toolItem.toolset.absoluteURL()
        let newFileName = title + ".bundle"
        let fm = FileManager.default
        //1.name
        if toolItem.title != title {
            let oldURL = setURL.appendingPathComponent(toolItem.fileName())
            let newURL = setURL.appendingPathComponent(newFileName)
            try? fm.moveItem(at: oldURL, to: newURL)
            toolItem.title = title
        }
        let bundleURL = toolItem.toolset.absoluteURL().appendingPathComponent(newFileName)
        //2.code
        let scriptName = "main." + scriptType
        if let scriptData = scriptText.data(using: String.Encoding.utf8) {
            let scriptURL = bundleURL.appendingPathComponent(scriptName)
            try? scriptData.write(to:scriptURL)
            toolItem.scriptFile = scriptName
        }
        //3.icon
        if let iconFileURL = iconURL {
            let targetURL = bundleURL.appendingPathComponent("icon.png")
            //remove old icon
            try? fm.removeItem(at: targetURL)
            try? fm.copyItem(at: iconFileURL, to: targetURL)
        }
    }
    
    //delete tool item
    func doDeleteTool(_ toolItem: ToolItem) {
        let path = toolItem.path()
        let fm = FileManager.default
        try? fm.removeItem(atPath: path)
    }
    
    //delete toolset
    func doDeleteToolset(_ toolset: ToolSet) {
        let path = toolset.absolutePath()
        let fm = FileManager.default
        try? fm.removeItem(atPath: path)
    }
    
    //save order
    func doSaveToolsetOrder(_ toolset: ToolSet) {
        var configData: [String:Any]?
        let configPath = toolset.configPath()
        if let data = NSData.init(contentsOfFile: configPath) {
            configData = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [String:Any]
        }
        var sortList = [String].init()
        for item in toolset.children {
            if item is ToolItem {
                let toolItem = item as! ToolItem
                sortList.append(toolItem.fileName())
            }else if item is ToolSet {
                let toolSet = item as! ToolSet
                sortList.append(toolSet.title)
            }
        }
        if configData == nil {
            configData = [String:Any].init()
        }
        configData!["sort"] = sortList
        let fm = FileManager.default
        if !fm.fileExists(atPath: configPath) {
            fm.createFile(atPath: configPath, contents: nil, attributes: nil)
        }
        if let fileData = try? JSONSerialization.data(withJSONObject: configData!, options: JSONSerialization.WritingOptions.init(rawValue: 0)) {
            let fileURL = URL.init(fileURLWithPath: configPath)
            try? fileData.write(to: fileURL)
        }
    }
    
    //add app
    func doAddApp(title: String, appId: String, iconURL:URL?, parent: ToolSet) -> ToolItem? {
        let groupPath = parent.absolutePath()
        let groupURL = URL.init(fileURLWithPath: groupPath)
        
        ///everything is okay, now let's create it
        //1.tool bundle
        let bundleName = title + ".bundle"
        let bundleURL = groupURL.appendingPathComponent(bundleName)
        let fm = FileManager.default
        try? fm.createDirectory(at: bundleURL, withIntermediateDirectories: true, attributes: nil)
        //2.save app
        let appFilename = "app.json"
        let appURL = bundleURL.appendingPathComponent(appFilename)
        let appPath = appURL.path
        let appInfo = ["id":appId]
        if let infoText = appInfo.jsonText() {
            let data = infoText.data(using: String.Encoding.utf8)
            let result = fm.createFile(atPath: appPath, contents: data, attributes: nil)
            if !result {
                return nil;
            }
        }
        
        //3.icon
        if let iconFileURL = iconURL {
            let targetURL = bundleURL.appendingPathComponent("icon.png")
            try? fm.copyItem(at: iconFileURL, to: targetURL)
        }
        let toolItem = ToolItem.init()
        toolItem.title = title
        toolItem.appId = appId
        toolItem.toolset = parent
        parent.children.append(toolItem)
        return toolItem
    }
    
    
}
