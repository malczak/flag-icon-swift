//
//  FlagIcons.swift
//  LastDay
//
//  Created by Mateusz Malczak on 17/09/16.
//  Copyright © 2016 The Pirate Cat. All rights reserved.
//

import Foundation


class SpriteSheet {
    
    typealias GridSize = (cols: Int, rows: Int)
    
    typealias ImageSize = (width: Int, height: Int)
    
    struct SheetInfo {
        private(set) var gridSize: GridSize
        
        private(set) var spriteSize: ImageSize
        
        private(set) var codes: [String]
        
    }
    
    private(set) var info: SheetInfo
    
    private(set) var image: UIImage
    
    private(set) var colorSpace: CGColorSpace
    
    private var imageData: UnsafeMutablePointer<Void>?
    
    private var imageCache = [String:UIImage]()
    
    private var cgImage: CGImage {
        return image.CGImage!
    }
    
    var bitsPerComponent: Int {
        return CGImageGetBitsPerComponent(cgImage)
    }
    
    var bitsPerPixel: Int {
        return bitsPerComponent * 4
    }
    
    var imageSize: CGSize {
        return image.size
    }
    
    var spriteBytesPerRow: Int {
        return 4 * info.spriteSize.width
    }
    
    var spriteBytesCount: Int {
        return spriteBytesPerRow * info.spriteSize.height
    }
    
    var sheetBytesPerRow: Int {
        return spriteBytesPerRow * info.gridSize.rows
    }
    
    var sheetBytesPerCol: Int {
        return spriteBytesCount * info.gridSize.cols
    }
    
    var sheetBytesCount: Int {
        return sheetBytesPerRow * Int(imageSize.height)
    }
    
    
    var bitmapInfo: CGBitmapInfo {
        let imageBitmapInfo = CGImageGetBitmapInfo(cgImage)
        let imageAlphaInfo = CGImageGetAlphaInfo(cgImage)
        return CGBitmapInfo(rawValue:
            (imageBitmapInfo.rawValue & (CGBitmapInfo.ByteOrderMask.rawValue)) |
                (imageAlphaInfo.rawValue & (CGBitmapInfo.AlphaInfoMask.rawValue)))
    }
    
    var bytes: UnsafeMutablePointer<UInt8> {
        return UnsafeMutablePointer<UInt8>(imageData!)
    }
    
    init?(sheetImage: UIImage, info sInfo: SheetInfo) {
        image = sheetImage
        info = sInfo
        guard let cgImage = sheetImage.CGImage else {
            return nil
        }
        
        guard let cgColorSpace = CGImageGetColorSpace(cgImage) else {
            return nil
        }
        colorSpace = cgColorSpace
        
        
        let bytes = UnsafeMutablePointer<Void>.alloc(sheetBytesCount)
        guard let bmpCtx = CGBitmapContextCreate(bytes, Int(imageSize.width), Int(imageSize.height), bitsPerComponent, 4 * Int(imageSize.width), colorSpace, bitmapInfo.rawValue) else {
            bytes.dealloc(sheetBytesCount)
            return
        }
        imageData = bytes
        CGContextDrawImage(bmpCtx, CGRectMake(0,0,imageSize.width,imageSize.height), cgImage)
    }
    
    func getImageFor(code: String, deepCopy: Bool = false, scale: CGFloat = 2) -> UIImage? {
        var cimg = imageCache[code]
        if nil == cimg || deepCopy {
            let data = getBytesFor(code)
            
            if deepCopy {
                guard let bmpCtx = CGBitmapContextCreate(nil, info.spriteSize.width, info.spriteSize.height, bitsPerComponent, 4 * info.spriteSize.width, colorSpace, bitmapInfo.rawValue) else {
                    return nil
                }
                
                let bmpData = CGBitmapContextGetData(bmpCtx)
                var srcData = UnsafeMutablePointer<UInt8>(data)
                var curData = UnsafeMutablePointer<UInt8>(bmpData)
                for _ in 0..<info.spriteSize.height {
                    curData.assignFrom(srcData, count: spriteBytesPerRow)
                    curData = curData.advancedBy(spriteBytesPerRow)
                    srcData = srcData.advancedBy(sheetBytesPerRow)
                }
                
                if let bmpImage = CGBitmapContextCreateImage(bmpCtx) {
                    return UIImage(CGImage: bmpImage, scale: scale, orientation: UIImageOrientation.Up).imageWithRenderingMode(.AlwaysOriginal)
                }
            }
            
            guard let provider = CGDataProviderCreateWithData(nil, data, sheetBytesPerRow * info.spriteSize.height, {_ in}) else {
                return nil
            }
            
            guard let cgImage = CGImageCreate(info.spriteSize.width, info.spriteSize.height, bitsPerComponent, bitsPerPixel, sheetBytesPerRow, colorSpace, bitmapInfo, provider, nil, true, CGColorRenderingIntent.RenderingIntentDefault) else {
                return nil
            }
            cimg = UIImage(CGImage: cgImage)
            imageCache[code] = cimg
        }
        
        return cimg
    }
    
    func getBytesFor(code: String) -> UnsafePointer<UInt8> {
        let idx = info.codes.indexOf(code.lowercaseString) ?? 0
        let dx = idx % info.gridSize.cols
        let dy = Int(Double(idx) / Double(info.gridSize.rows))
        let data = bytes.advancedBy(sheetBytesPerCol * dy + spriteBytesPerRow * dx)
        return UnsafePointer<UInt8>(data)
    }
    
    deinit {
        imageCache.removeAll()
        if let data = imageData {
            data.dealloc(sheetBytesCount)
        }
        imageData = nil
    }
    
}

class FlagIcons {
    
    class func loadSheetFrom(file: String) -> SpriteSheet? {
        if let infoData = NSData(contentsOfFile: file) {
            do {
                let infoObj = try NSJSONSerialization.JSONObjectWithData(infoData, options: NSJSONReadingOptions(rawValue: 0))
                if let gridSizeObj = infoObj["gridSize"] as? [String:Int],
                    let spriteSizeObj = infoObj["spriteSize"] as? [String:Int] {
                    let gridSize = (gridSizeObj["cols"]!, gridSizeObj["rows"]!)
                    let spriteSize = (spriteSizeObj["width"]!, spriteSizeObj["height"]!)
                    
                    if let codes = (infoObj["codes"] as? String)?.componentsSeparatedByString("|") {
                        if let sheetFileName = infoObj["sheetFile"] as? String, let resourceUrl = NSBundle.mainBundle().resourceURL,
                            let sheetFileUrl = resourceUrl.URLByAppendingPathComponent(sheetFileName) {
                            if let image = UIImage(contentsOfFile: sheetFileUrl.path!) {
                                let info = SpriteSheet.SheetInfo(gridSize: gridSize, spriteSize: spriteSize, codes: codes)
                                return SpriteSheet(sheetImage: image, info:  info)
                            }
                        }
                    }
                }
            } catch {
            }
        }
        return nil
    }
   
}
