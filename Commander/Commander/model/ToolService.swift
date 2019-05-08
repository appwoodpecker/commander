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
                    //path
                    path = parentSet.path.appendingPathComponent(name)
                    if title != nil && scriptFileName != nil && path != nil {
                        let toolItem = ToolItem.init()
                        toolItem.title = title
                        toolItem.scriptFile = scriptFile
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
        //sort children
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
        sortedChildren.append(contentsOf: leftItems)
        parentSet.children = sortedChildren
    }
}
