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

extension NSImage {
    func roundCorners(withRadius radius: CGFloat) -> NSImage {
        let rect = NSRect(origin: NSPoint.zero, size: size)
        if
            let cgImage = self.cgImage,
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 4 * Int(size.width),
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
            context.beginPath()
            context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
            context.closePath()
            context.clip()
            context.draw(cgImage, in: rect)
            
            if let composedImage = context.makeImage() {
                return NSImage(cgImage: composedImage, size: size)
            }
        }
        return self
    }
    
    func roundImage() -> NSImage {
        let width = self.size.width
        let height = self.size.height
        let radius = min(width, height)/2.0
        return self.roundCorners(withRadius: radius)
        
    }
}

fileprivate extension NSImage {
    var cgImage: CGImage? {
        var rect = CGRect.init(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }
}
