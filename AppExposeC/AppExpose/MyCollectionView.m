//
//  MyCollectionView.m
//  AppExposeC
//
//  Created by Dave Carlton on 8/29/22.
//

#import <Foundation/Foundation.h>
#import "MyCollectionView.h"
#import "IconViewBox.h"

@implementation MyCollectionView

- (void)awakeFromNib {
    [self setSubviewSize: 128.0];
}

- (NSView *)hitTest: (NSPoint) aPoint {
    [[AppDelegate shared] selectionChanged];
    return nil;
}

- (void)didAddSubview:(IconViewBox *)subview {
    
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
    
}

-(void)setSubviewSize:(CGFloat)theSubviewSize {
    [self setMaxItemSize:NSMakeSize(theSubviewSize,theSubviewSize)];
    [self setMinItemSize:NSMakeSize(theSubviewSize,theSubviewSize)];
}

@end
