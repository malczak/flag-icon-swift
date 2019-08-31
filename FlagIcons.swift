//
//  FlagIcons.swift
//  LastDay
//
//  Created by Mateusz Malczak on 17/09/16.
//  Copyright © 2016 The Pirate Cat. All rights reserved.
//

import Foundation
import UIKit

/**
 SpriteSheet class represents an image map
 */
open class SpriteSheet {
    
    typealias GridSize = (cols: Int, rows: Int)
    
    typealias ImageSize = (width: Int, height: Int)
    
    /**
     Struct stores information about a grid size, sprite size and country codes included in sprite sheet
     */
    struct SheetInfo {
        fileprivate(set) var gridSize: GridSize
        
        fileprivate(set) var spriteSize: ImageSize
        
        fileprivate(set) var codes: [String]
    }
    
    fileprivate(set) var info: SheetInfo
    
    fileprivate(set) var image: UIImage
    
    fileprivate(set) var colorSpace: CGColorSpace
    
    fileprivate var imageData: UnsafeMutableRawPointer?
    
    fileprivate var imageCache = [String:UIImage]()
    
    fileprivate var cgImage: CGImage {
        return image.cgImage!
    }
    
    var bitsPerComponent: Int {
        return cgImage.bitsPerComponent
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
        let imageBitmapInfo = cgImage.bitmapInfo
        let imageAlphaInfo = cgImage.alphaInfo
        return CGBitmapInfo(rawValue:
            (imageBitmapInfo.rawValue & (CGBitmapInfo.byteOrderMask.rawValue)) |
                (imageAlphaInfo.rawValue & (CGBitmapInfo.alphaInfoMask.rawValue)))
    }
    
    var bytes: UnsafeMutablePointer<UInt8> {
        return imageData!.assumingMemoryBound(to: UInt8.self)
    }
    
    init?(sheetImage: UIImage, info sInfo: SheetInfo) {
        image = sheetImage
        info = sInfo
        guard let cgImage = sheetImage.cgImage else {
            return nil
        }
        
        guard let cgColorSpace = cgImage.colorSpace else {
            return nil
        }
        colorSpace = cgColorSpace
        
        
        let memory = (sheetBytesCount * MemoryLayout<UInt8>.stride,
                      MemoryLayout<UInt8>.alignment)
        let bytes = UnsafeMutableRawPointer.allocate(byteCount: memory.0,
                                                     alignment: memory.1)
        guard let bmpCtx = CGContext(data: bytes,
                                     width: Int(imageSize.width),
                                     height: Int(imageSize.height),
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: 4 * Int(imageSize.width),
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo.rawValue) else {
                                        bytes.deallocate()
                                        return
        }
        
        imageData = bytes
        bmpCtx.draw(cgImage, in: CGRect(x: 0,y: 0,width: imageSize.width,height: imageSize.height))
    }
    
    open func getImageFor(_ code: String, deepCopy: Bool = false, scale: CGFloat = 2) -> UIImage? {
        var cimg = imageCache[code]
        if nil == cimg || deepCopy {
            let data = getBytesFor(code)
            
            if deepCopy {
                guard let bmpCtx = CGContext(data: nil,
                                             width: info.spriteSize.width,
                                             height: info.spriteSize.height,
                                             bitsPerComponent: bitsPerComponent,
                                             bytesPerRow: spriteBytesPerRow,
                                             space: colorSpace,
                                             bitmapInfo: bitmapInfo.rawValue) else {
                                                return nil
                }
                
                if let bmpData = bmpCtx.data {
                    var srcData = UnsafeMutablePointer<UInt8>(mutating: data.bytes)
                    var curData = bmpData.assumingMemoryBound(to: UInt8.self)
                    for _ in 0..<info.spriteSize.height {
                        curData.assign(from: srcData, count: spriteBytesPerRow)
                        curData = curData.advanced(by: spriteBytesPerRow)
                        srcData = srcData.advanced(by: sheetBytesPerRow)
                    }
                    
                    if let bmpImage = bmpCtx.makeImage() {
                        return UIImage(cgImage: bmpImage, scale: scale, orientation: UIImage.Orientation.up).withRenderingMode(.alwaysOriginal)
                    }
                }
                
                return nil
            }
            
            let expectedSize = sheetBytesPerRow * info.spriteSize.height
            let size = min(expectedSize, data.size)
            guard let provider = CGDataProvider(dataInfo: nil,
                                                data: data.bytes,
                                                size: size,
                                                releaseData: {_,_,_  in}) else {
                                                    return nil
            }
            
            guard let cgImage = CGImage(width: info.spriteSize.width,
                                        height: info.spriteSize.height,
                                        bitsPerComponent: bitsPerComponent,
                                        bitsPerPixel: bitsPerPixel,
                                        bytesPerRow: sheetBytesPerRow,
                                        space: colorSpace,
                                        bitmapInfo: bitmapInfo,
                                        provider: provider,
                                        decode: nil,
                                        shouldInterpolate: true,
                                        intent: CGColorRenderingIntent.defaultIntent) else {
                                            return nil
            }
            cimg = UIImage(cgImage: cgImage)
            imageCache[code] = cimg
        }
        
        return cimg
    }
    
    open func getBytesFor(_ code: String) -> (bytes: UnsafePointer<UInt8>, size: Int) {
        let idx = info.codes.firstIndex(of: code.lowercased()) ?? 0
        let dx = idx % info.gridSize.cols
        let dy = Int(Double(idx) / Double(info.gridSize.rows))
        let bytesOffset = sheetBytesPerCol * dy + spriteBytesPerRow * dx
        let data = bytes.advanced(by: bytesOffset)
        let totalMemory = sheetBytesCount * MemoryLayout<UInt8>.stride
        return (UnsafePointer<UInt8>(data), totalMemory - bytesOffset)
    }
    
    deinit {
        imageCache.removeAll()
        if let data = imageData {
            data.deallocate()
        }
        imageData = nil
    }
    
}

/**
 Represents a flags icon sprite sheet
 */
open class FlagIcons {
    
    open class func loadDefault() -> SpriteSheet? {
        guard let assetsBundle = assetsBundle() else {
            return nil
        }
        
        if let infoFile = assetsBundle.path(forResource: "flags", ofType: "json") {
            return self.loadSheetFrom(infoFile)
        }
        
        return nil
    }
    
    open class func loadSheetFrom(_ file: String) -> SpriteSheet? {
        guard let assetsBundle = assetsBundle() else {
            return nil
        }
        
        if let infoData = try? Data(contentsOf: URL(fileURLWithPath: file)) {
            do {
                if let infoObj = try JSONSerialization.jsonObject(with: infoData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String:Any] {
                    if let gridSizeObj = infoObj["gridSize"] as? [String:Int],
                        let spriteSizeObj = infoObj["spriteSize"] as? [String:Int] {
                        let gridSize = (gridSizeObj["cols"]!, gridSizeObj["rows"]!)
                        let spriteSize = (spriteSizeObj["width"]!, spriteSizeObj["height"]!)
                        
                        if let codes = (infoObj["codes"] as? String)?.components(separatedBy: "|") {
                            if let sheetFileName = infoObj["sheetFile"] as? String,
                                let resourceUrl = assetsBundle.resourceURL {
                                let sheetFileUrl = resourceUrl.appendingPathComponent(sheetFileName)
                                if let image = UIImage(contentsOfFile: sheetFileUrl.path) {
                                    let info = SpriteSheet.SheetInfo(gridSize: gridSize, spriteSize: spriteSize, codes: codes)
                                    return SpriteSheet(sheetImage: image, info:  info)
                                }
                            }
                        }
                    }
                }
            } catch {
            }
        }
        return nil
    }
    
    fileprivate class func assetsBundle() -> Bundle? {
        let bundle = Bundle(for: self)
        guard let assetsBundlePath = bundle.path(forResource: "assets", ofType: "bundle") else {
            return nil
        }
        return Bundle(path: assetsBundlePath);
    }
    
}
