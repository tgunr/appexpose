//
//  AppDelegate.h
//  AppExpose
//
//  Created by Dave Carlton on 1/5/12.
//  Copyright (c) 2012 PolyMicro Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
//    MyWindowController *myWindowController;
}

@property (assign) IBOutlet MyWindowController *myWindowController;
@property(assign) IBOutlet NSWindow       *window;
@property(weak) IBOutlet NSCollectionView *iconCollection;
@property (weak) IBOutlet NSBrowser *appBrowser;
@property (weak) IBOutlet NSSegmentedControl *iconAppearance;

- (IBAction)changeAppearance:(id)sender;
-(IBAction)openReadMe:(id)sender;
@end
