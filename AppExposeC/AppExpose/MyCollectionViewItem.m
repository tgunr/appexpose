//
//  MyCollectionViewItem.m
//  AppExposeC
//
//  Created by Dave Carlton on 8/29/22.
//

#import <Foundation/Foundation.h>
#import "MyCollectionViewItem.h"
#import "IconViewBox.h"

@implementation MyCollectionViewItem

- (NSView *)hitTest: (NSPoint) aPoint {
    return nil;
}

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    [(IconViewBox*)[self view] setSelected:flag];
    [(IconViewBox*)[self view] setNeedsDisplay:YES];
}

@end

