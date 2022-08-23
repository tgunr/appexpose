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
    AuthorizationRef myAuthorizationRef;
    MyWindowController *myWindowController;
    NSWindow       *window;
    NSCollectionView *iconCollection;
    NSBrowser *appBrowser;
    NSSegmentedControl *iconAppearance;
}

@property (strong)  IBOutlet MyWindowController *myWindowController;
@property (strong)  IBOutlet NSWindow *window;
@property (strong)  IBOutlet NSCollectionView *iconCollection;
@property (strong)  IBOutlet NSBrowser *appBrowser;
@property (strong)  IBOutlet NSSegmentedControl *iconAppearance;

+ (id)shared;
- (IBAction)openReadMe:(id)sender;
- (void)selectionChanged;

@end
