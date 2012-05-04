/*
     File: MyWindowController.m 
 Abstract: This sample's main window controller object.
  
  Version: 1.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "MyWindowController.h"
#import "AppDelegate.h"

@implementation MyWindowController
@synthesize selectAllToolBarItem;
@synthesize restartFinder;
@synthesize progressIndicator;

@synthesize viewController;
@synthesize zoomSlider;
@synthesize selectAllButton;
@synthesize appearanceControl;
@synthesize iconView;
@synthesize iconsView;
@synthesize removeButton;
@synthesize applyButton;
@synthesize finder;

- (void)awakeFromNib
{
    [[self window] setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
    [[self window] setContentBorderThickness:30 forEdge:NSMinYEdge];
    
    // load our nib that contains the collection view
    [self willChangeValueForKey:@"viewController"];
    viewController = [[MyViewController alloc] initWithNibName:@"Collection" bundle:nil];
    [self didChangeValueForKey:@"viewController"];
    
    [myTargetView addSubview:[viewController view]];
    
    // make sure we resize the viewController's view to match its super view
    [[viewController view] setFrame:[myTargetView bounds]];
    
    [viewController setSortingMode:0];		// ascending sort order
    [[AppDelegate shared] setMyWindowController:self];
    [applyButton setEnabled:NO];
    [removeButton setEnabled:NO];

}

//-(void)showBeforeAppearance {
//	[viewController showBeforeAppearance];
//    [applyButton setEnabled:NO];
//    [removeButton setEnabled:NO];
//}
//
//-(void)showAfterAppearance {
//	[viewController showAfterAppearance];
//}
//
- (IBAction)changeAppearance:(id)sender {
    NSInteger segment = [sender selectedSegment];
    switch (segment) {
        case 0: {
            [viewController showBeforeAppearance];
            [applyButton setEnabled:NO];
            [removeButton setEnabled:NO];
            [selectAllButton setEnabled:NO];
            break;
        }
        case 1: {
            [viewController showAfterAppearance];
            [selectAllButton setEnabled:YES];
            break;
        }
        default:
            break;
    }
}


- (IBAction)applyIcons:(id)sender {
    [viewController applyIcons];
}

- (IBAction)removeIcons:(id)sender {
    [viewController removeIcons];
}

- (void)setSelectAllLabel {
    NSArray *entries = [viewController selectedIcons]; 
    NSUInteger numberSelected = [entries count];
    NSUInteger numberOfCollection = [[viewController contentArray] count];
    if (numberSelected == numberOfCollection) {
        [selectAllToolBarItem setLabel:@"Select None"];
    } else {
        [selectAllToolBarItem setLabel:@"Select All"];
    }
}

- (IBAction)selectAll:(id)sender {
    NSString *label = [selectAllToolBarItem label];
    if ([label isEqualToString:@"Select All"]) {
        [selectAllToolBarItem setLabel:@"Select None"];
        [viewController selectAll: sender];
    } else {
        [selectAllToolBarItem setLabel:@"Select All"];
        [viewController selectNone: sender];
    }
    [self selectionChanged];
}

- (void)selectionChanged {
    NSInteger segment = [appearanceControl selectedSegment];
    switch (segment) {
        case 0: {
            [applyButton setEnabled:NO];
            [removeButton setEnabled:NO];
            [selectAllButton setEnabled:NO];
            break;
        }
        case 1: {
            NSArray *entries = [viewController selectedIcons]; 
            NSUInteger numberEntries = [entries count];
            if (numberEntries) {
                [applyButton setEnabled:YES];
                [removeButton setEnabled:YES];
            } else {
                [applyButton setEnabled:NO];
                [removeButton setEnabled:NO];
            }
            [self setSelectAllLabel];
            break;
        }
        default:
            break;
    }

}

- (IBAction)zoomChanged:(id)sender {
    NSInteger value = [zoomSlider integerValue];
//    int scales[] = { 32, 64, 128, 256, 512, 1024 } ;
//    int scale = scales[value];
    PMLOG(2,@"zoom: %f", (CGFloat)value);
    [viewController zoomChanged: (CGFloat)value];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"QuitFinder")
    {
        if([keyPath isEqualToString:@"isTerminated"])
        {
            [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.apple.finder" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:NULL launchIdentifier:NULL];
            [object removeObserver:self forKeyPath:@"isTerminated"];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)restartFinder:(id)sender {
    NSArray* apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.finder"];
    if([apps count])
    {
        finder = [apps objectAtIndex:0];
        [finder addObserver:self forKeyPath:@"isTerminated" options:0 context:@"QuitFinder"];
        [finder terminate];
    }
}
@end
