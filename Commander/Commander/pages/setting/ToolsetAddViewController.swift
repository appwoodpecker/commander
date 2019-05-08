//
//  ToolsetAddViewController.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/7.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolsetAddViewController: NSViewController {

    @IBOutlet weak var iconImageView: NSImageView!
    
    @IBOutlet weak var nameTextfield: NSTextField!
    
    var toolset: ToolSet!
    var completionCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func iconButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
    }
    
    
}
