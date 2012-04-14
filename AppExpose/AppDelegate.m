//
//  AppDelegate.m
//  AppExpose
//
//  Created by Dave Carlton on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AppEntry.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
	NSString *appDirectory;
	NSArray *dirItems;
	NSString *dirPath;
	AppEntry *rootEntry;
	__weak NSBrowser *appBrowser;
}

@synthesize window = _window;
@synthesize iconCollection = _iconCollection;
@synthesize appBrowser;


- (id)init {
    self = [super init];
    if (self) {
	    rootEntry = [AppEntry rootEntry];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSSystemDomainMask, YES);
	appDirectory = [paths objectAtIndex: 0];
	if ([paths count] > 0)  {
        appDirectory = [paths objectAtIndex:0];
    }
	appDirectory = [appDirectory stringByAppendingString: @"/"];
    NSURL *root = [NSURL fileURLWithPath:appDirectory];
    [self readFromURL:root];
    [appBrowser loadColumnZero];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

// -------------------------------------------------------------------------------
//	openReadMe:sender
// -------------------------------------------------------------------------------
- (IBAction)openReadMe:(id)sender
{
	NSString* fullPath = [[NSBundle mainBundle] pathForResource:@"ReadMe" ofType:@"txt"];
	[[NSWorkspace sharedWorkspace] openFile:fullPath];
}

- (void)addEntries:(NSArray *)array {
    // This method is called on the main thread when a background read operation has entries to be added to the entry tree and displayed
    for (AppEntry *entry in array) 
        [entry addToRootEntry:rootEntry];
}

- (void)readFromURL: (NSURL *) absoluteURL {
	AppEntry       *entry;
	NSError * error;
	NSMutableArray *entryArray = [NSMutableArray array];

	if (absoluteURL) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *const path = [absoluteURL path];
		dirItems = [fm contentsOfDirectoryAtPath: path error: &error];

		for (NSString *item in dirItems) {
			entry = [[AppEntry alloc] initWithPath: [path stringByAppendingFormat:@"/%@", item]];
			[entryArray addObject: entry];
		}
		[self addEntries: entryArray];
	}
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
