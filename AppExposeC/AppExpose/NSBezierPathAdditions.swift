//  Converted to Swift 5.6.1 by Swiftify v5.6.26165 - https://swiftify.com/
/*
    File:  NSBezierPathAdditions.swift

    Abstract:  NSBezierPath convenience nethods for drawing rectangles with rounded corners

    Version:  1.0

    Copyright:  � Copyright 2005 Apple Computer, Inc. All rights reserved.

    Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
    ("Apple") in consideration of your agreement to the following terms, and your
    use, installation, modification or redistribution of this Apple software
    constitutes acceptance of these terms.  If you do not agree with these terms,
    please do not use, install, modify or redistribute this Apple software.

    In consideration of your agreement to abide by the following terms, and subject
    to these terms, Apple grants you a personal, non-exclusive license, under Apple�s
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

extension NSBezierPath {
    convenience init?(roundedRect rect: NSRect, cornerRadius radius: Float) {
        let result = self.init()
        result.append(withRoundedRect: rect, cornerRadius: radius)
        return result
    }

    func append(withRoundedRect rect: NSRect, cornerRadius radius: Float) {
        if !NSIsEmptyRect(rect) {
            if radius > 0.0 {
                // Clamp radius to be no larger than half the rect's width or height.
                let clampedRadius = Float(min(radius, 0.5 * Double(min(rect.size.width, rect.size.height))))

                let topLeft = NSPoint(x: rect.minX, y: rect.maxY)
                let topRight = NSPoint(x: rect.maxX, y: rect.maxY)
                let bottomRight = NSPoint(x: rect.maxX, y: rect.minY)

                move(to: NSPoint(x: rect.midX, y: rect.maxY))
                appendArc(from: topLeft, to: rect.origin as? NSPoint ?? NSPoint.zero, radius: CGFloat(clampedRadius))
                appendArc(from: rect.origin as? NSPoint ?? NSPoint.zero, to: bottomRight, radius: CGFloat(clampedRadius))
                appendArc(from: bottomRight, to: topRight, radius: CGFloat(clampedRadius))
                appendArc(from: topRight, to: topLeft, radius: CGFloat(clampedRadius))
                close()
            } else {
                // When radius == 0.0, this degenerates to the simple case of a plain rectangle.
                appendRect(rect)
            }
        }
    }
}