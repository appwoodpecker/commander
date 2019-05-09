//
//  AutorunUtil.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/9.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa
import ServiceManagement

class AutorunUtil: NSObject {
    
    // Adding Login Items Using a Shared File List
    // This is a combination of the code provided by the following Stackoverflow discussion
    // http://stackoverflow.com/questions/26475008/swift-getting-a-mac-app-to-launch-on-startup
    // (This approach will not work with App-Sandboxing.)
    
    class func applicationIsInStartUpItems() -> Bool {
        return itemReferencesInLoginItems().existingReference != nil
    }
    
    class func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let enabled = (itemReferences.existingReference != nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileList?
        
        if loginItemsRef != nil {
            if !enabled {
                let appUrl = NSURL.init(fileURLWithPath:Bundle.main.bundlePath)
                LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
                print("Application was added to login items")
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    print("Application was removed from login items")
                }
            }
        }
    }
    
    class func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
        let itemUrl = UnsafeMutablePointer<Unmanaged<CFURL>?>.allocate(capacity: 1)
        let appUrl = NSURL.init(fileURLWithPath:Bundle.main.bundlePath)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileList?
        
        if loginItemsRef != nil {
            if let loginItems = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as? [LSSharedFileListItem] {
                print("There are \(loginItems.count) login items")
                if(loginItems.count > 0) {
                    let lastItem = loginItems.last
                    for currentItem in loginItems {
                        if LSSharedFileListItemResolve(currentItem, 0, itemUrl, nil) == noErr {
                            if let urlRef: NSURL = itemUrl.pointee?.takeRetainedValue() {
                                if urlRef.isEqual(appUrl) {
                                    return (currentItem, lastItem)
                                }
                            }
                        }
                        else {
                            print("Unknown login application")
                        }
                    }
                    // The application was not found in the startup list
                    return (nil, lastItem)
                    
                } else  {
                    let addatstart: LSSharedFileListItem = kLSSharedFileListItemBeforeFirst.takeRetainedValue()
                    return(nil,addatstart)
                }
            }
            
        }
        return (nil, nil)
    }
    
    
}
