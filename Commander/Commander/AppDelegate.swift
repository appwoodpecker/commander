//
//  AppDelegate.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/5.
//  Copyright © 2019 lifebetter. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    var controller: StatusMenuController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let controller = StatusMenuController.init()
        controller.window = self.window;
        controller.setup()
        self.controller = controller;
    }
    
    
   
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }


}
