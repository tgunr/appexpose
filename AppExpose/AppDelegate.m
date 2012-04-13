//
//  AppDelegate.m
//  AppExpose
//
//  Created by Dave Carlton on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate {
	NSString *appDirectory;
	NSArray *dirItems;
	NSString *dirPath;
}

@synthesize window = _window;
@synthesize appBrowser = _appBrowser;
@synthesize iconCollection = _iconCollection;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

#pragma mark NSBrowser Data Source Methods
- (id)rootItemForBrowser:(NSBrowser *)browser {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSApplicationDirectory, NSSystemDomainMask, YES);
    if ([paths count] > 0)  {
        appDirectory = [paths objectAtIndex:0];
    }
    return appDirectory;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError * error;
	dirPath = item;
	dirItems = [fm contentsOfDirectoryAtPath: item  error: &error];
	NSUInteger number = [dirItems count];
    return number;
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item  {
    NSString *itemAtIndex = [dirItems objectAtIndex: (NSUInteger)index];
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
    return item;
}


@end
