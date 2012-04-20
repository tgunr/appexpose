//
//  AppDelegate.m
//  AppExpose
//
//  Created by Dave Carlton on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AppEntry.h"
#import "MyWindowController.h"

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
//    [appBrowser loadColumnZero];
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


/*
- (id)rootItemForBrowser:(NSBrowser *)browser {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSApplicationDirectory, NSSystemDomainMask, YES);
    if ([paths count] > 0)  {
        appDirectory = [paths objectAtIndex:0];
    }
    dirPath = appDirectory;
	PMLOG(1, @"root: %@", appDirectory);
    return appDirectory;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError * error;
    NSString *fullPath;
    if ([item isEqualToString: appDirectory])
        fullPath = item;
    else
        fullPath = [dirPath stringByAppendingFormat:@"/%@", item];
	dirPath = fullPath;

	dirItems = [fm contentsOfDirectoryAtPath: dirPath  error: &error];
	NSUInteger number = [dirItems count];
    PMLOG(1, @"item: %@ number: %d", item, number);
    return number;
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item  {
    NSString *itemAtIndex = [dirItems objectAtIndex: (NSUInteger)index];
    PMLOG(1, @"item: %@ index: %d itemAtIndex: %@", item, index, itemAtIndex);
	return itemAtIndex;
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
	if ([item isEqualToString: appDirectory])
		return NO;
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir;
    NSString *fullPath = [dirPath stringByAppendingFormat:@"/%@", item];
	BOOL result = [fm fileExistsAtPath: fullPath isDirectory: &isDir];
    // The "None" filter are the leaf items. Except that the root filter is also a "None" filter just to supply the source image, se we need to special case the root item.
    return !isDir;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    PMLOG(1, @"item: %@", item);
    return item;
}
  */

@end
