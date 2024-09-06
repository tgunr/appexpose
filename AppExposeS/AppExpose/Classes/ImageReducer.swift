//
// Created by Dave Carlton on 7/28/17.
// Copyright (c) 2017 Polymicro Systems. All rights reserved.
//

import AppKit
import Foundation
import QuartzCore

class ImageReducer: NSObject {
    // Input Image
    var inputBitmapImageRep: NSBitmapImageRep? {
        didSet(newInputBitmapImageRep) {
//            self.inputBitmapImageRep = newInputBitmapImageRep
            // Create a CIImage from the NSBitmapImageRep,
            // and make it inputImage to the first CIFilter in our filter pipeline.
            inputCIImage = CIImage(bitmapImageRep: inputBitmapImageRep!)
            scaleTransformFilter?.setValue(inputCIImage, forKey: "inputImage")
            // Update the result image.
            updateOutputImage()
        }
    }

    var inputCIImage: CIImage?

    // Filter Chain Bookkeeping
    var finalFilter: CIFilter?

    // Stage 1: Resampling Parameters

    var scalesImage: Bool = false {
        didSet {
            updateOutputImage()
        }
    }

    var maxPixelsWide: Int = 0 {
        didSet {
            updateOutputImage()
        }
    }

    var maxPixelsHigh: Int = 0 {
        didSet {
            updateOutputImage()
        }
    }

    var scaleTransformFilter: CIFilter?

    // Stage 2: Sharpening Parameters
    var sharpensImage: Bool = false {
        didSet {
            updateOutputImage()
        }
    }

    var unsharpMaskFilter: CIFilter?

    // Stage 3: Border and Background Parameters
    var drawBorder: Bool = false {
        didSet {
            updateOutputImage()
        }
    }

    var borderCornerRadius: Float = 0.0 {
        didSet {
            updateOutputImage()
        }
    }

    var borderThickness: Float = 0.0 {
        didSet {
            updateOutputImage()
        }
    }

    var borderColor: NSColor? {
        didSet {
            updateOutputImage()
        }
    }

    // Stage 4: Shadow Parameters
    var addsShadow: Bool = false {
        didSet {
            updateOutputImage()
        }
    }

//    var shadow: NSShadow?

//    override class func initialize() {
//        if self == ImageReducer.self {
//            self.setKeys(["inputBitmapImageRep", "maxPixelsWide", "maxPixelsHigh", "addsShadow"],
//                    triggerChangeNotificationsForDependentKey: "outputPixelsWide")
//            self.setKeys(["inputBitmapImageRep", "maxPixelsWide", "maxPixelsHigh", "addsShadow"],
//                    triggerChangeNotificationsForDependentKey: "outputPixelsHigh")
//        }
//    }

    func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [String: Any]?,
        context: UnsafeMutableRawPointer?) {
//        if object  == unsharpMaskFilter || object == shadow {
        updateOutputImage()
//        }
    }

    override init() {
        super.init()
        scalesImage = true
        maxPixelsWide = 400
        maxPixelsHigh = 1000
        sharpensImage = true
        drawBorder = true
        borderCornerRadius = 0.0
        borderThickness = 2.0
        borderColor = NSColor.white
        addsShadow = true
        // TODO: Fix shadow
//        shadow = NSShadow()
//        shadow?.shadowOffset = NSSize(width: 6, height: -4)
//        shadow?.shadowBlurRadius = 9.0
        scaleTransformFilter = CIFilter(name: "CILanczosScaleTransform")
        scaleTransformFilter?.setDefaults()
//        unsharpMaskFilter = CIFilter(name: "CIUnsharpMask")
//        unsharpMaskFilter?.setDefaults()
//        unsharpMaskFilter?.setValue(scaleTransformFilter?.value(forKey: "outputImage"), forKey: "inputImage")
//        unsharpMaskFilter?.addObserver(self, forKeyPath: "inputIntensity", options: [], context: nil)
//        unsharpMaskFilter?.addObserver(self, forKeyPath: "inputRadius", options: [], context: nil)
//        shadow?.addObserver(self, forKeyPath: "shadowBlurRadius", options: [], context: nil)
//        self.setKeys(["inputBitmapImageRep", "maxPixelsWide", "maxPixelsHigh", "addsShadow"],
//                     triggerChangeNotificationsForDependentKey: "outputPixelsWide")
//        self.setKeys(["inputBitmapImageRep", "maxPixelsWide", "maxPixelsHigh", "addsShadow"],
//                     triggerChangeNotificationsForDependentKey: "outputPixelsHigh")
    }

    // MARK: -

    // MARK: *** Filter Accessors ***

    var scaleFactor: CGFloat {
        let sourceBitmap: NSBitmapImageRep? = inputBitmapImageRep
        if sourceBitmap != nil && scalesImage {
            // Determine scale factor needed to fit within size constraints.
            let widthScale = Float(maxPixelsWide) / Float((sourceBitmap?.pixelsWide)!)
            let heightScale = Float(maxPixelsHigh) / Float((sourceBitmap?.pixelsHigh)!)
            return CGFloat(min(1.0, min(Double(widthScale), Double(heightScale))))
        } else {
            return 1.0
        }
    }

    func outputBitmapImageRep() -> NSBitmapImageRep {
        var bitmapImageRep: NSBitmapImageRep?
        let ciImage = outputCIImage()
        // Get the CIImage's extents.  The filters we're using in this example should always produce an output image of finite extent, but in the general case one needs to account for the possibility of the output image being infinite in extent.
        var extent: CGRect = ciImage.extent
        if extent.isInfinite {
            extent.size.width = 1024
            extent.size.height = 1024
            print(#function, "-[\(self) \(#function)] Trimmed infinite rect to arbitrary finite rect")
        }
        // Compute size of output bitmap.
        let outputBitmapSize: NSSize = NSMakeSize(CGFloat(outputPixelsWide()), CGFloat(outputPixelsHigh()))
        // Create a new NSBitmapImageRep that matches the CIImage's extents.
        bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(outputBitmapSize.width), pixelsHigh: Int(outputBitmapSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
        // Create an NSGraphicsContext that draws into the NSBitmapImageRep, and make it current.
        let nsContext = NSGraphicsContext(bitmapImageRep: bitmapImageRep!)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsContext
        // Clear the bitmap to zero alpha.
        NSColor.clear.set()
        NSMakeRect(0, 0, CGFloat(bitmapImageRep!.pixelsWide), CGFloat(bitmapImageRep!.pixelsHigh)).fill()
        // Decide where the image will go.
        var imageDestinationRect = CGRect(
            x: 0.0,
            y: CGFloat(bitmapImageRep!.pixelsHigh) - extent.size.height,
            width: extent.size.width,
            height: extent.size.height)
        // Create the path for the border (if any).
        var borderPath: NSBezierPath?
        NSGraphicsContext.saveGraphicsState()
        if drawBorder {
            borderPath = NSBezierPath(
                roundedRect: NSInsetRect(
                    imageDestinationRect,
                    0.5 * CGFloat(borderThickness),
                    0.5 * CGFloat(borderThickness)),
                xRadius: CGFloat(borderCornerRadius),
                yRadius: CGFloat(borderCornerRadius))
//            if addsShadow {
//                NSGraphicsContext.saveGraphicsState()
//                shadow?.set()
//                NSColor.white.set()
//                borderPath?.fill()
//                NSGraphicsContext.restoreGraphicsState()
//            }
            borderPath?.addClip()
        }
//        else if addsShadow {
//                borderPath = NSBezierPath(rect: imageDestinationRect)
//                NSGraphicsContext.saveGraphicsState()
//                shadow?.set()
//                NSColor.white.set()
//                borderPath?.fill()
//                NSGraphicsContext.restoreGraphicsState()
//            }

        // Get a CIContext from the NSGraphicsContext, and use it to draw the CIImage into the NSBitmapImageRep.
        let ciContext: CIContext? = nsContext?.ciContext
        ciContext?.draw(ciImage, in: imageDestinationRect, from: extent)
        NSGraphicsContext.restoreGraphicsState()
        // Draw the border path.
        if drawBorder && borderPath != nil {
            borderPath?.lineWidth = CGFloat(borderThickness)
            borderColor?.set()
            borderPath?.stroke()
        }
        // Restore the previous NSGraphicsContext.
        NSGraphicsContext.restoreGraphicsState()
        // Return the new NSBitmapImageRep.
        return bitmapImageRep!
    }

    func outputPixelsWide() -> Int {
        var result: Int
//        if addsShadow {
//            result = Int(ceil(scaleFactor *
//                CGFloat((inputBitmapImageRep?.pixelsWide)!) +
//                fabs(shadow!.shadowOffset.width) +
//                shadow!.shadowBlurRadius))
//        } else {
        result = Int(floor(scaleFactor * CGFloat((inputBitmapImageRep?.pixelsWide)!)))
//        }
        return result
    }

    func outputPixelsHigh() -> Int {
        var result: Int
//        if addsShadow {
//            result = Int(ceil(scaleFactor *
//                CGFloat((inputBitmapImageRep?.pixelsHigh)!) +
//                fabs(shadow!.shadowOffset.height) +
//                shadow!.shadowBlurRadius))
//        } else {
        result = Int(floor(scaleFactor * CGFloat((inputBitmapImageRep?.pixelsWide)!)))
//        }
        return result
    }

    func outputCIImage() -> CIImage {
        let r: CIImage = finalFilter!.value(forKey: "outputImage") as! CIImage
        return (finalFilter != nil &&
            inputBitmapImageRep != nil) ? r : inputCIImage!
    }
}

extension ImageReducer {
    func setInputImage(_ newInputImage: NSImage!) {
        inputBitmapImageRep = BitmapImageRepFromNSImage(nsImage: newInputImage!)
    }

    func outputImage() -> CIImage? {
        var result: NSImage?
        if inputBitmapImageRep != nil {
            let outputCIImage = self.outputCIImage()
            let extent: CGRect = outputCIImage.extent
            if extent.isInfinite {
                print(#function, "*** OUTPUT IMAGE HAS INFINITE EXTENT ***")
            } else {
                result = NSImage(size: NSMakeSize(CGFloat(extent.size.width), CGFloat(extent.size.height)))
                let ciImageRep = NSCIImageRep(ciImage: outputCIImage)
                result?.addRepresentation(ciImageRep)
            }
        }

        let imageData = result?.tiffRepresentation!
        let ciImage = CIImage(data: imageData!)

        return ciImage
    }
}

extension ImageReducer {
    func updateOutputImage() {
        willChangeValue(forKey: "outputCIImage")
        clearFilterChain()
        if scalesImage {
            scaleTransformFilter?.setValue(scaleFactor, forKey: "inputScale")
            add(scaleTransformFilter!)
        }
//        if sharpensImage {
//            add(unsharpMaskFilter!)
//        }
        didChangeValue(forKey: "outputCIImage")
    }

    func clearFilterChain() {
        finalFilter = nil
    }

    func add(_ aFilter: CIFilter) {
        var v: CIImage
        if finalFilter != nil {
            v = finalFilter?.value(forKey: "outputImage") as! CIImage
        } else {
            v = inputCIImage!
        }
        aFilter.setValue(v, forKey: "inputImage")
        finalFilter = aFilter
    }
}

private func BitmapImageRepFromNSImage(nsImage: NSImage) -> NSBitmapImageRep {
    // See if the NSImage has an NSBitmapImageRep.
    // If so, return the first NSBitmapImageRep encountered.
    // An NSImage that is initialized by loading the contents of a bitmap image file
    // (such as JPEG, TIFF, or PNG) and, not subsequently rescaled,
    // will usually have a single NSBitmapImageRep.
    let enumerator: NSEnumerator? = (nsImage.representations as NSArray).objectEnumerator()
    while let representation = enumerator?.nextObject() {
        if representation is NSBitmapImageRep {
            return (representation as? NSBitmapImageRep)!
        }
    }

    // If we didn't find an NSBitmapImageRep (perhaps because we received a PDF image),
    // we can create one using one of two approaches: (1) lock focus on the NSImage,
    // and create the bitmap using -[NSBitmapImageRep initWithFocusedViewRect:],
    // or (2) (Tiger and later) create an NSBitmapImageRep,
    // and an NSGraphicsContext that draws into it using
    // +[NSGraphicsContext graphicsContextWithBitmapImageRep:], and
    // composite the NSImage into the bitmap graphics context.
    // We'll use approach (1) here, since it is simple and supported on all versions of Mac OS X.
    let size: NSSize = nsImage.size
    nsImage.lockFocus()
    let bitmapImageRep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, size.width, size.height))
    nsImage.unlockFocus()
    return bitmapImageRep!
}
