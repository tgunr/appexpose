//
//  MyScrollView.m
//  AppExposeC
//
//  Created by Dave Carlton on 8/29/22.
//

#import <Foundation/Foundation.h>
#import "MyScrollView.h"

@implementation MyScrollView

- (void)awakeFromNib {
    // set up the background gradient for this custom scrollView
    backgroundGradient = [[NSGradient alloc] initWithStartingColor:
            [NSColor colorWithDeviceRed: 0.349f green: 0.6f blue: 0.898f alpha: 0.0f]
                                                       endingColor: [NSColor colorWithDeviceRed: 0.349f green: 0.6f blue: .898f alpha: 0.4f]];
}

- (void)drawRect: (NSRect) rect {
    // draw our special background as a gradient
    [backgroundGradient drawInRect: [self documentVisibleRect] angle: 90.0f];
}

@end
