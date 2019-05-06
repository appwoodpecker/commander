//
//  IndexViewController.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/5.
//  Copyright © 2019 lifebetter. All rights reserved.
//

import Cocoa

class IndexViewController: NSViewController {
    
    @IBOutlet weak var tabview: NSTabView!
    @IBOutlet weak var addLayout: NSView!
    @IBOutlet weak var editLayout: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addVC = AddViewController.init(nibName: "AddViewController", bundle: nil)
        let addView = addVC.view
        addView.autoresizingMask = NSView.AutoresizingMask.init(rawValue:(NSView.AutoresizingMask.width.rawValue | NSView.AutoresizingMask.height.rawValue))
        self.addLayout.addSubview(addView)
        
        let editVC = EditViewController.init(nibName: "EditViewController", bundle: nil)
        let editView = editVC.view
        editView.autoresizingMask = NSView.AutoresizingMask.init(rawValue:(NSView.AutoresizingMask.width.rawValue | NSView.AutoresizingMask.height.rawValue))
        self.editLayout.addSubview(editView)
    }    
}
