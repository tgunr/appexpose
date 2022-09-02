//
//  IconViewBox.m
//  AppExposeC
//
//  Created by Dave Carlton on 8/29/22.
//

#import <Foundation/Foundation.h>
#import "MyScrollView.h"
#import "IconViewBox.h"
#import "MyViewController.h"
#import "AppExposeC-Swift.h"

@implementation IconViewBox

// -------------------------------------------------------------------------------
//    hitTest:aPoint
// -------------------------------------------------------------------------------
@synthesize labelField;
@synthesize imageView;
@synthesize selected;

- (IconViewBox *)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
    
//- (void)awakeFromNib {
//    (MyViewController *)vc = [[[AppDelegate shared] windowController] viewController];
//}
//

- (IconViewBox *)hitTest: (NSPoint) aPoint {
    // don't allow any mouse clicks for subviews in this NSBox
    [[AppDelegate shared] selectionChanged];
    selected = YES;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self setBoxType:NSBoxSecondary];
    [self setBorderType:NSBezelBorder];
}

- (IBAction)iconSelected:(id)sender {
}
@end
