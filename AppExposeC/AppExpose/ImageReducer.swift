//  Converted to Swift 5.6.1 by Swiftify v5.6.26165 - https://swiftify.com/
/*
    File:  ImageReducer.swift

    Abstract:  Demonstrates basic image processing using Core Image + AppKit

    Version:  1.0

    Copyright:  © Copyright 2005 Apple Computer, Inc. All rights reserved.

    Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
    ("Apple") in consideration of your agreement to the following terms, and your
    use, installation, modification or redistribution of this Apple software
    constitutes acceptance of these terms.  If you do not agree with these terms,
    please do not use, install, modify or redistribute this Apple software.

    In consideration of your agreement to abide by the following terms, and subject
    to these terms, Apple grants you a personal, non-exclusive license, under Apple’s
    copyrights in this original Apple software (the "Apple Software"), to use,
    reproduce, modify and redistribute the Apple Software, with or without
    modifications, in source and/or binary forms; provided that if you redistribute
    the Apple Software in its entirety and without modifications, you must retain
    this notice and the following text and disclaimers in all such redistributions of
    the Apple Software.  Neither the name, trademarks, service marks or logos of
    Apple Computer, Inc. may be used to endorse or promote products derived from the
    Apple Software without specific prior written permission from Apple.  Except as
    expressly stated in this notice, no other rights or licenses, express or implied,
    are granted by Apple herein, including but not limited to any patent rights that
    may be infringed by your derivative works or by other works in which the Apple
    Software may be incorporated.

    The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
    WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
    WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
    PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
    COMBINATION WITH YOUR PRODUCTS.

    IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
    GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
    OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
    (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Cocoa
import Quartz
import QuartzCore

class ImageReducer: NSObject {
    // Input Image
    var inputBitmapImageRep: NSBitmapImageRep?
    var inputCIImage: CIImage?
    // Filter Chain Bookkeeping
    var finalFilter: CIFilter?
    // Stage 1: Resampling Parameters
    var scalesImage = false
    var maxPixelsWide = 0
    var maxPixelsHigh = 0
    var scaleTransformFilter: CIFilter?
    // Stage 2: Sharpening Parameters
    var sharpensImage = false
    var unsharpMaskFilter: CIFilter?
    // Stage 3: Border and Background Parameters
    var drawBorder = false
    var borderCornerRadius: Float = 0.0
    var borderThickness: Float = 0.0
    var borderColor: NSColor?
    // Stage 4: Shadow Parameters
    var addsShadow = false
    var shadow: NSShadow?

    //+ (void)initialize {
    //    if (self == [ImageReducer class]) {
    //        [self setKeys:[NSArray arrayWithObjects:@"inputBitmapImageRep", @"maxPixelsWide", @"maxPixelsHigh", @"addsShadow", nil]];
    //         [self setKeys:[NSArray arrayWithObjects:@"inputBitmapImageRep", @"maxPixelsWide", @"maxPixelsHigh", @"addsShadow", nil]];
    //    }
    //}

    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {

        var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)

        if key == "outputPixelsWide" {
            let affectingKeys = [
                "inputBitmapImageRep",
                "maxPixelsWide",
                "maxPixelsHigh",
                "addsShadow"
            ]
            keyPaths = keyPaths + Set<AnyHashable>(affectingKeys)
        }
        if key == "outputPixelsHigh" {
            let affectingKeys = [
                "inputBitmapImageRep",
                "maxPixelsWide",
                "maxPixelsHigh",
                "addsShadow"
            ]
            keyPaths = keyPaths + Set<AnyHashable>(affectingKeys)
        }
        return keyPaths
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? CIFilter) == unsharpMaskFilter || (object as? NSShadow) == shadow {
            updateOutputImage()
        }
    }

    // MARK: *** Initializers ***
    override init() {
        super.init()
        scalesImage = true
        maxPixelsWide = 400
        maxPixelsHigh = 1000
        sharpensImage = true
        drawBorder = true
        borderCornerRadius = 0.0
        borderThickness = 2.0
        borderColor = .white
        addsShadow = true
        shadow = NSShadow()
        shadow?.shadowOffset = NSMakeSize(6, -4)
        shadow?.shadowBlurRadius = 9.0

        scaleTransformFilter = CIFilter(name: "CILanczosScaleTransform")
        scaleTransformFilter?.setDefaults()

        unsharpMaskFilter = CIFilter(name: "CIUnsharpMask")
        unsharpMaskFilter?.setDefaults()

        unsharpMaskFilter?.setValue(scaleTransformFilter?.value(forKey: "outputImage"), forKey: "inputImage")
        return self
    }

    func initWithObservers() {
        super.init()
        self.init()
        unsharpMaskFilter?.addObserver(self, forKeyPath: "inputIntensity", options: [], context: nil)
        unsharpMaskFilter?.addObserver(self, forKeyPath: "inputRadius", options: [], context: nil)

        shadow?.addObserver(self, forKeyPath: "shadowBlurRadius", options: [], context: nil)
        return self
    }

    // MARK: -
    // MARK: *** Input Image Accessors ***
    func inputBitmapImageRep() -> NSBitmapImageRep? {
        return inputBitmapImageRep
    }

    func setInputBitmapImageRep(_ newInputBitmapImageRep: NSBitmapImageRep?) {
        if inputBitmapImageRep != newInputBitmapImageRep {

            inputBitmapImageRep = newInputBitmapImageRep

            // Create a CIImage from the NSBitmapImageRep, and make it inputImage to the first CIFilter in our filter pipeline.
            if let inputBitmapImageRep = inputBitmapImageRep {
                inputCIImage = CIImage(bitmapImageRep: inputBitmapImageRep)
            }
            scaleTransformFilter?.setValue(inputCIImage, forKey: "inputImage")

            // Update the result image.
            updateOutputImage()
        }
    }

    // MARK: -
    // MARK: *** Stage 1: Resampling Parameters ***
    func scalesImage() -> Bool {
        return scalesImage
    }

    func setScalesImage(_ flag: Bool) {
        if scalesImage != flag {
            scalesImage = flag
            updateOutputImage()
        }
    }

    func maxPixelsWide() -> Int {
        return maxPixelsWide
    }

    func setMaxPixelsWide(_ newMaxPixelsWide: Int) {
        if maxPixelsWide != newMaxPixelsWide {
            maxPixelsWide = newMaxPixelsWide
            updateOutputImage()
        }
    }

    func maxPixelsHigh() -> Int {
        return maxPixelsHigh
    }

    func setMaxPixelsHigh(_ newMaxPixelsHigh: Int) {
        if maxPixelsHigh != newMaxPixelsHigh {
            maxPixelsHigh = newMaxPixelsHigh
            updateOutputImage()
        }
    }

    // MARK: -
    // MARK: *** Stage 2: Sharpening Parameters ***
    func sharpensImage() -> Bool {
        return sharpensImage
    }

    func setSharpensImage(_ flag: Bool) {
        if sharpensImage != flag {
            sharpensImage = flag
            updateOutputImage()
        }
    }

    // MARK: -
    // MARK: *** Stage 3: Border and Background Parameters ***
    func drawBorder() -> Bool {
        return drawBorder
    }

    func setDrawBorder(_ flag: Bool) {
        if drawBorder != flag {
            drawBorder = flag
            updateOutputImage()
        }
    }

    func borderCornerRadius() -> Float {
        return borderCornerRadius
    }

    func setBorderCornerRadius(_ newBorderCornerRadius: Float) {
        if borderCornerRadius != newBorderCornerRadius {
            borderCornerRadius = newBorderCornerRadius
            updateOutputImage()
        }
    }

    func borderThickness() -> Float {
        return borderThickness
    }

    func setBorderThickness(_ newBorderThickness: Float) {
        if borderThickness != newBorderThickness {
            borderThickness = newBorderThickness
            updateOutputImage()
        }
    }

    func borderColor() -> NSColor? {
        return borderColor
    }

    func setBorderColor(_ newBorderColor: NSColor?) {
        if borderColor != newBorderColor {
            borderColor = newBorderColor

            updateOutputImage()
        }
    }

    // MARK: -
    // MARK: *** Stage 4: Shadow Parameters ***
    func addsShadow() -> Bool {
        return addsShadow
    }

    func setAddsShadow(_ flag: Bool) {
        if addsShadow != flag {
            addsShadow = flag
            updateOutputImage()
        }
    }

    func shadow() -> NSShadow? {
        return shadow
    }

    // MARK: -
    // MARK: *** Filter Accessors ***

    func scaleFactor() -> Float {
        let sourceBitmap = inputBitmapImageRep()
        if sourceBitmap != nil && scalesImage() {
            // Determine scale factor needed to fit within size constraints.
            let widthScale = Float(maxPixelsWide()) / Float(sourceBitmap?.pixelsWide ?? 0.0)
            let heightScale = Float(maxPixelsHigh()) / Float(sourceBitmap?.pixelsHigh ?? 0.0)
            return Float(min(1.0, min(widthScale, heightScale)))
        } else {
            return 1.0
        }
    }

    func unsharpMaskFilter() -> CIFilter? {
        return unsharpMaskFilter
    }

    // MARK: -
    // MARK: *** Output Image Accessors ***

    func outputBitmapImageRep() -> NSBitmapImageRep? {
        var bitmapImageRep: NSBitmapImageRep? = nil

        let ciImage = outputCIImage()
        if let ciImage = ciImage {

            // Get the CIImage's extents.  The filters we're using in this example should always produce an output image of finite extent, but in the general case one needs to account for the possibility of the output image being infinite in extent.
            let extent = ciImage.extent
            if extent.isInfinite {
                extent.size.width = 1024
                extent.size.height = 1024
                print("-[\(self) \(NSStringFromSelector(#function))] Trimmed infinite rect to arbitrary finite rect")
            }

            // Compute size of output bitmap.
            let outputBitmapSize = NSMakeSize(CGFloat(outputPixelsWide()), CGFloat(outputPixelsHigh()))

            // Create a new NSBitmapImageRep that matches the CIImage's extents.
            bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(outputBitmapSize.width), pixelsHigh: Int(outputBitmapSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)

            // Create an NSGraphicsContext that draws into the NSBitmapImageRep, and make it current.
            var nsContext: NSGraphicsContext? = nil
            if let bitmapImageRep = bitmapImageRep {
                nsContext = NSGraphicsContext(bitmapImageRep: bitmapImageRep)
            }
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = nsContext

            // Clear the bitmap to zero alpha.
            NSColor.clear.set()
            NSRect(x: 0, y: 0, width: CGFloat(bitmapImageRep?.pixelsWide ?? 0.0), height: CGFloat(bitmapImageRep?.pixelsHigh ?? 0.0)).fill()

            // Decide where the image will go.
            var imageDestinationRect = CGRect(x: 0.0, y: CGFloat(bitmapImageRep?.pixelsHigh ?? 0.0) - extent.size.height, width: extent.size.width, height: extent.size.height)

            // Create the path for the border (if any).
            var borderPath: NSBezierPath? = nil
            NSGraphicsContext.saveGraphicsState()
            if drawBorder {
                borderPath = NSBezierPath(roundedRect: &imageDestinationRect as? NSRect?.insetBy(dx: CGFloat(0.5 * borderThickness), dy: CGFloat(0.5 * borderThickness)), cornerRadius: borderCornerRadius)

                if addsShadow {
                    NSGraphicsContext.saveGraphicsState()
                    shadow?.set()
                    NSColor.white.set()
                    borderPath?.fill()
                    NSGraphicsContext.restoreGraphicsState()
                }

                borderPath?.addClip()
            } else if addsShadow {
                borderPath = NSBezierPath(rect: &imageDestinationRect as? NSRect)
                NSGraphicsContext.saveGraphicsState()
                shadow?.set()
                NSColor.white.set()
                borderPath?.fill()
                NSGraphicsContext.restoreGraphicsState()
            }

            // Get a CIContext from the NSGraphicsContext, and use it to draw the CIImage into the NSBitmapImageRep.
            let ciContext = nsContext?.ciContext
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
        }

        // Return the new NSBitmapImageRep.
        return bitmapImageRep
    }

    func outputPixelsWide() -> Int {
        var result: Int
        if addsShadow {
            result = ceil(CGFloat(scaleFactor() * Float(inputBitmapImageRep()?.pixelsWide ?? 0.0) + abs(Float(shadow?.shadowOffset.width ?? 0.0))) + (shadow?.shadowBlurRadius ?? 0.0))
        } else {
            result = floor(scaleFactor() * Float(inputBitmapImageRep()?.pixelsWide ?? 0.0))
        }
        return result
    }

    func outputPixelsHigh() -> Int {
        var result: Int
        if addsShadow {
            result = ceil(CGFloat(scaleFactor() * Float(inputBitmapImageRep()?.pixelsHigh ?? 0.0) + abs(Float(shadow?.shadowOffset.height ?? 0.0))) + (shadow?.shadowBlurRadius ?? 0.0))
        } else {
            result = floor(scaleFactor() * Float(inputBitmapImageRep()?.pixelsHigh ?? 0.0))
        }
        return result
    }

    // MARK: -
    // MARK: *** Output Image Accessors ***
    func outputCIImage() -> CIImage? {
        return (finalFilter != nil && inputBitmapImageRep() != nil) ? (finalFilter?.value(forKey: "outputImage") as? CIImage) : inputCIImage
    }
}

extension ImageReducer {
    // This is a convenience setter that gets or creates an inputBitmapImageRep from an NSImage.
    func setInputImage(_ newInputImage: NSImage?) {
        inputBitmapImageRep = BitmapImageRepFromNSImage(newInputImage)
    }

    // This is a convenience getter that wraps the outputBitmapImageRep in an NSImage.
    func outputImage() -> NSImage? {
        var result: NSImage? = nil
        if inputBitmapImageRep() != nil {
            let outputCIImage = self.outputCIImage()
            if let outputCIImage = outputCIImage {
                let extent = outputCIImage.extent
                if extent.isInfinite {
                    print("*** OUTPUT IMAGE HAS INFINITE EXTENT ***")
                } else {
                    result = NSImage(size: NSMakeSize(extent.size.width, extent.size.height))
                    let ciImageRep = NSCIImageRep(ciImage: outputCIImage)
                    result?.addRepresentation(ciImageRep)
                }
            }
        }
        return result
    }
}

private func BitmapImageRepFromNSImage(_ nsImage: NSImage?) -> NSBitmapImageRep? {
    // See if the NSImage has an NSBitmapImageRep.  If so, return the first NSBitmapImageRep encountered.  An NSImage that is initialized by loading the contents of a bitmap image file (such as JPEG, TIFF, or PNG) and, not subsequently rescaled, will usually have a single NSBitmapImageRep.
    let enumerator = (nsImage?.representations as NSArray?).objectEnumerator()
    var representation: NSImageRep?
    while representation = enumerator?.nextObject() as? NSImageRep {
        if representation is NSBitmapImageRep {
            return representation as? NSBitmapImageRep
        }
    }

    // If we didn't find an NSBitmapImageRep (perhaps because we received a PDF image), we can create one using one of two approaches: (1) lock focus on the NSImage, and create the bitmap using -[NSBitmapImageRep initWithFocusedViewRect:], or (2) (Tiger and later) create an NSBitmapImageRep, and an NSGraphicsContext that draws into it using +[NSGraphicsContext graphicsContextWithBitmapImageRep:], and composite the NSImage into the bitmap graphics context.  We'll use approach (1) here, since it is simple and supported on all versions of Mac OS X.
    let size = nsImage?.size
    nsImage?.lockFocus()
    let bitmapImageRep = NSBitmapImageRep(focusedViewRect: NSRect(x: 0, y: 0, width: size?.width ?? 0.0, height: size?.height ?? 0.0))
    nsImage?.unlockFocus()

    return bitmapImageRep
}

extension ImageReducer {
    func updateOutputImage() {
        willChangeValue(forKey: "outputCIImage")

        clearFilterChain()

        if scalesImage() {
            scaleTransformFilter?.setValue(NSNumber(value: scaleFactor()), forKey: "inputScale")
            add(scaleTransformFilter)
        }

        if sharpensImage() {
            add(unsharpMaskFilter)
        }

        didChangeValue(forKey: "outputCIImage")
    }

    func clearFilterChain() {
        finalFilter = nil
    }

    func add(_ aFilter: CIFilter?) {
        var aFilter = aFilter
        aFilter?.setValue(finalFilter != nil ? (finalFilter?.value(forKey: "outputImage") as? CIImage) : inputCIImage, forKey: "inputImage")
        finalFilter = aFilter
    }
}