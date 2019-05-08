//
//  Extension.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Foundation
import AppKit


extension String {
    
    func appendingPathComponent(_ path: String) -> String {
        let slashText = "/"
        let hasSlash = self.hasSuffix(slashText) || path.hasPrefix(slashText)
        var mPath = ""
        mPath.append(self)
        if !hasSlash {
            mPath.append(slashText)
        }
        mPath.append(path)
        return mPath
    }
    
    //test.py -> py
    func pathExtension() -> String? {
        let path = self
        let components = path.components(separatedBy: ".")
        var ext :String?
        if components.count > 1 {
            ext = components.last
        }
        return ext
    }
}
