//
//  AppDelegate.m
//  AppExpose
//
//  Created by Dave Carlton on 1/5/12.
//  Copyright (c) 2012 PolyMicro Systems. All rights reserved.
//

#import "AppDelegate.h"
#import "AppEntry.h"
#import "MyWindowController.h"
#ifdef DEBUG
#warning Using FSCRIPT 
#import "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk/Library/Frameworks/FScript.framework/Headers/FScript.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate {
	NSString *appDirectory;
	NSArray *dirItems;
	NSString *dirPath;
	AppEntry *rootEntry;
}

@synthesize myWindowController;
@synthesize window;
@synthesize iconCollection;
@synthesize appBrowser;
@synthesize iconAppearance;

+ (id)shared
{
    static dispatch_once_t onceQueue;
    static AppDelegate *appDelegate = nil;
    
    dispatch_once(&onceQueue, ^{ appDelegate = [[self alloc] init]; });
    return appDelegate;
}

- (id)init {
    self = [super init];
    if (self) {
	    rootEntry = [AppEntry rootEntry];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    OSStatus myStatus;
//    myStatus = AuthorizationCreate (NULL, kAuthorizationEmptyEnvironment,
//                                    kAuthorizationFlagDefaults, &myAuthorizationRef);
//    AuthorizationFlags myFlags;
//    myFlags = kAuthorizationFlagDefaults |
//    kAuthorizationFlagExtendRights |
//    kAuthorizationFlagInteractionAllowed |
//    kAuthorizationFlagPreAuthorize;
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSSystemDomainMask, YES);
	appDirectory = [paths objectAtIndex: 0];
	if ([paths count] > 0) {
		appDirectory = [paths objectAtIndex: 0];
	}
	appDirectory = [appDirectory stringByAppendingString: @"/"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL debug = [defaults boolForKey:@"debug"];
    if (debug) {
        appDirectory = @"/Users/davec/Applications/";
    }
    NSString *directory = [defaults stringForKey:@"path"];
    if (directory) {
        appDirectory = directory;
    }
	myWindowController.viewController.url = [NSURL fileURLWithPath: appDirectory];
#ifdef DEBUG
    [[NSApp mainMenu] addItem:[[FScriptMenuItem alloc] init]];
#endif
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (IBAction)openReadMe:(id)sender
{
	NSString* fullPath = [[NSBundle mainBundle] pathForResource:@"ReadMe" ofType:@"txt"];
	[[NSWorkspace sharedWorkspace] openFile:fullPath];
}

#pragma mark NSBrowser Data Source Methods
- (id)rootItemForBrowser:(NSBrowser *)browser {
    return rootEntry;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    return [[(AppEntry *)item childEntries] count];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    return [[(AppEntry *)item childEntries] objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    return [(AppEntry *)item isLeaf];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    return [(AppEntry *)item name];
}

- (void)selectionChanged {
    [myWindowController selectionChanged]; 
}

@end
