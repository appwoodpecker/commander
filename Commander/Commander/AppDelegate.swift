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
    var controller: MenuController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Config.shared().setupEnvt()
        otherSetting()
        let controller = MenuController.shared()
        controller.window = self.window;
        controller.setup()
        self.controller = controller;
    }
    
    func otherSetting() {
        //disable smart quote
        UserDefaults.standard.set(false, forKey: "NSAutomaticQuoteSubstitutionEnabled")
    }
   
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }


}

