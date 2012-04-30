//
//  AppEntry.m
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

#import "AppEntry.h"
#import <XATTR/xattr.h>
#import "CompositeView.h"

@interface NSImage (Dump)
- (void)dump;
@end

@implementation NSImage (Dump)
- (void)dump {
	NSBitmapImageRep *imageRep = [[self representations] objectAtIndex: 0];
	NSData           *data     = [imageRep representationUsingType: NSPNGFileType properties: nil];
	[data writeToFile: @"/tmp/image.png" atomically: NO];
}

@end

@implementation AppEntry {
}
@synthesize isLeaf;
@synthesize isApp;
@synthesize canAccess;
@synthesize name;
@synthesize appURL;
@synthesize childEntries;
@synthesize iconImage;
@synthesize originalImage;
@synthesize iconDictionary;
@synthesize isFolder;
@synthesize attributes;
@synthesize xattr;
@synthesize myCompositeView;

+ (AppEntry *)rootEntry {
	return [[self alloc] initRootWithURL: [NSURL fileURLWithPath: @"/"]];
}

- (AppEntry *)initRootWithURL: (NSURL *) url {
	self = [super init];
	if (self) {
		appURL         = [url copy];
		isLeaf         = YES;
		isApp          = NO;
		name           = [[url lastPathComponent] copy];
		originalImage  = [[NSWorkspace sharedWorkspace] iconForFile: [appURL path]];
		iconImage      = originalImage;
		iconDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				                                      iconImage, KEY_IMAGE,
				                                      name, KEY_NAME,
				                                      nil];
	}
	return self;
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)imageFrame
{
    // [super drawImage:image withFrame:imageFrame inView:controlView];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:5 yRadius:5];
    [path addClip];
    
    //set the size
    [image setSize:imageFrame.size];
    
    //draw the image
    [image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawRect:(NSRect)dirtyRect
{
        NSRect imageBounds = NSMakeRect((CGFloat)0.0, (CGFloat)0.0, kMyViewWidth, kMyViewHeight);
        NSRect bounds = imageBounds;
        NSAffineTransform *transform;
        CGFloat alignStroke;
        CGFloat resolution;
        CGFloat stroke;
        NSBezierPath *path;
        NSRect drawRect;
        NSGradient *gradient;
        NSColor *color;
        NSColor *color2;
        resolution = 72 * (CGFloat)0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        transform = [NSAffineTransform transform];
        [transform scaleXBy:(bounds.size.width / imageBounds.size.width) yBy:(bounds.size.height / imageBounds.size.height)];
        [transform translateXBy:bounds.origin.x yBy:bounds.origin.y];
        [transform concat];
        
        // Layer 1
        
        stroke = (CGFloat)1.0;
        stroke *= resolution;
        if (stroke < (CGFloat)1.0) {
            stroke = (CGFloat)ceil(stroke);
        } else {
            stroke = (CGFloat)round(stroke);
        }
        stroke /= resolution;
        alignStroke = (CGFloat)fmod((CGFloat)0.5 * stroke * resolution, (CGFloat)1.0);
        path = [NSBezierPath bezierPath];
        drawRect = NSMakeRect((CGFloat)5.5, (CGFloat)5.5, (CGFloat)117.0, (CGFloat)117.0);
        drawRect.origin.x = ((CGFloat)round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
        drawRect.origin.y = ((CGFloat)round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
        drawRect.size.width = (CGFloat)round(resolution * drawRect.size.width) / resolution;
        drawRect.size.height = (CGFloat)round(resolution * drawRect.size.height) / resolution;
        [path appendBezierPathWithRoundedRect:drawRect xRadius:(CGFloat)4.0 yRadius:(CGFloat)4.0];
        [path setWindingRule:NSEvenOddWindingRule];
        color = [NSColor colorWithCalibratedRed:(CGFloat)1.0 green:(CGFloat)1.0 blue:(CGFloat)1.0 alpha:(CGFloat)1.0];
        color2 = [NSColor colorWithCalibratedRed:(CGFloat)1.0 green:(CGFloat)1.0 blue:(CGFloat)1.0 alpha:(CGFloat)1.0];
        gradient = [[NSGradient alloc] initWithStartingColor:color endingColor:color2];
        [gradient drawInBezierPath:path angle:(CGFloat)90.0];
        color = [NSColor colorWithCalibratedRed:(CGFloat)0.0 green:(CGFloat)0.0 blue:(CGFloat)0.0 alpha:(CGFloat)1.0];
        [color setStroke];
        [path setLineWidth:stroke];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path setLineJoinStyle:NSRoundLineJoinStyle];
        [path stroke];
        
        alignStroke = (CGFloat)0.0;
        path = [NSBezierPath bezierPath];
        drawRect = NSMakeRect((CGFloat)0.5, (CGFloat)0.5, (CGFloat)127.5, (CGFloat)127.5);
        drawRect.origin.x = ((CGFloat)round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
        drawRect.origin.y = ((CGFloat)round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
        drawRect.size.width = (CGFloat)round(resolution * drawRect.size.width) / resolution;
        drawRect.size.height = (CGFloat)round(resolution * drawRect.size.height) / resolution;
        [path appendBezierPathWithRoundedRect:drawRect xRadius:(CGFloat)8.0 yRadius:(CGFloat)8.0];
        [path setWindingRule:NSEvenOddWindingRule];
        color = [NSColor colorWithCalibratedRed:(CGFloat)0.298 green:(CGFloat)0.298 blue:(CGFloat)0.298 alpha:(CGFloat)1.0];
        [color setStroke];
        stroke = (CGFloat)5.0;
        stroke *= resolution;
        if (stroke < (CGFloat)1.0) {
            stroke = (CGFloat)ceil(stroke);
        } else {
            stroke = (CGFloat)round(stroke);
        }
        stroke /= resolution;
        stroke *= (CGFloat)2.0;
        [path setLineWidth:stroke];
        [path setLineCapStyle:NSSquareLineCapStyle];
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [path addClip];
        [path stroke];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        
}


- (NSImage *)composeIcons {
    NSInteger numImages = [childEntries count];

    NSSize resultSize = NSMakeSize([iconImage size].width / 4.0, [iconImage size].height / 4.0);
	NSPoint point = {0.0, 0.0};
	NSImage  *resultImage   = [[NSImage alloc] initWithSize: [[self iconImage] size]];
    [resultImage lockFocus];

    [self drawRect:NSMakeRect(0.0, 0.0, 128.0, 128.0)];
    
    int i;
    int x = MIN(9, numImages);
    for (i=0; i<x; i++) {
        AppEntry *entry = [childEntries objectAtIndex:i];
        NSImage *imageToCompose  = [[entry iconImage] copy];
        [imageToCompose setSize:resultSize];
		[imageToCompose drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOut fraction:1.0];
        point.x += 8;
        point.y += 8;
	}
	[resultImage unlockFocus];

	return resultImage;
}

- (AppEntry *)initWithURL: (NSURL *) url {
	self = [super init];
	if (self) {

		appURL            = [url copy];
		NSError       *error;
		NSFileManager *fm = [[NSFileManager alloc] init];
		attributes    = [fm attributesOfItemAtPath: [url path] error: &error];
		xattr         = [[XATTR alloc] initWithURL: url options: nofollow];
		isLeaf        = [self isALeaf: url];
		isFolder      = [self isAFolder: url];
		isApp         = NO;
		canAccess     = [self userCanAccess];
		name          = [[url lastPathComponent] copy];
		originalImage = [[NSWorkspace sharedWorkspace] iconForFile: [appURL path]];
		[originalImage setSize: NSMakeSize(ICON_SIZE, ICON_SIZE)];
		iconImage      = originalImage;
		if ([[appURL pathExtension] isEqualToString: @"app"]) {
			isApp  = YES;
			isLeaf = !isLeaf;
		}
		else {
			childEntries = [[NSMutableArray alloc] init];
			if (isFolder && [self isNotSpecial]) {
				[self scanURLForIcons: url forEntry: self];
				if ([childEntries count]) {
					iconImage = [self composeIcons];
				}
			}
		}
		iconDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				                                      iconImage, KEY_IMAGE,
				                                      name, KEY_NAME,
				                                      nil];
	}
	if (!canAccess && !isApp) {
		[self badgeAsNoAccess];
	}
	return self;
}

- (BOOL)isNotSpecial {
    NSArray *specialNames = [NSArray arrayWithObjects: @"Utilities", nil];
    return ![specialNames containsObject: name];
}

- (NSArray *)scanURLForIcons: (NSURL *) directoryToScan forEntry: (AppEntry *) appEntry {
	// Create a local file manager instance
	NSFileManager *fm = [[NSFileManager alloc] init];

	// Enumerate the directory (specified elsewhere in your code)
	// Request the two properties the method uses, name and isDirectory
	// Ignore hidden files
	// The errorHandler: parameter is set to nil. Typically you'd want to present a panel
	NSArray *fileKeys = [NSArray arrayWithObjects: NSURLIsRegularFileKey, NSURLIsDirectoryKey, NSURLCustomIconKey, nil];

	NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL: directoryToScan
	                                includingPropertiesForKeys: fileKeys
							                           options: NSDirectoryEnumerationSkipsHiddenFiles
									              errorHandler: nil];

	// An array to store the all the enumerated file names in
	NSMutableArray *theArray = [NSMutableArray array];

	// Enumerate the dirEnumerator results, each value is stored in allURLs
	for (NSURL *theURL in dirEnumerator) {

		// Retrieve the file name. From NSURLNameKey, cached during the enumeration.
		NSString *fileName;
		[theURL getResourceValue: &fileName forKey: NSURLNameKey error: NULL];

		// Retrieve whether a directory. From NSURLIsDirectoryKey, also
		// cached during the enumeration.
		NSNumber *isDirectory;
		[theURL getResourceValue: &isDirectory forKey: NSURLIsDirectoryKey error: NULL];

		// Ignore files under the app directory
		if ([[theURL pathExtension] isEqualToString: @"app"]) {
			AppEntry *entry = [[AppEntry alloc] initWithURL: theURL];
			if ([appEntry addChildEntry: entry]) {
				[dirEnumerator skipDescendents];
			}
			else
				PMERR(1, @"Failed to add childEntry at: %@", [theURL path]);
		}
	}
	return theArray;
}

- (BOOL)isALeaf: (NSURL *) url {
	NSString *fileType = [attributes objectForKey: NSFileType];
	if ([fileType isEqualToString: NSFileTypeDirectory])
		return NO; // folders are not leafs
	if ([fileType isEqualToString: NSFileTypeSymbolicLink])
		return NO; // symlinks can't be a leaf for now
	if ([[url pathExtension] isEqualToString: @"app"])
		return NO; // nor are Apps
	return YES;
}

- (BOOL)isAFolder: (NSURL *) url {
	NSFileManager *fm             = [NSFileManager defaultManager];
	NSError       *error;
	NSDictionary  *fileAttributes = [fm attributesOfItemAtPath: [url path] error: &error];
	NSString      *fileType       = [fileAttributes objectForKey: NSFileType];
	if ([fileType isEqualToString: NSFileTypeSymbolicLink])
		return NO; // symlinks can't be a folder for now
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	return ![ws isFilePackageAtPath: [url path]];
}

- (BOOL)userCanAccess {
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL result1 = [fm isWritableFileAtPath: [appURL path]];
	NSError *error;
	BOOL result2 = [appURL checkResourceIsReachableAndReturnError: &error];
	if (!result1 || !result2) {
		PMLOG(1, @"no access: %@", appURL);
	}
	return result1 && result2;
}

- (NSString *)pathWithName {
	NSString *path = [[appURL path] stringByAppendingPathComponent: name];
	return isLeaf ? path : [path stringByAppendingString: @"/"];
}

- (NSComparisonResult)compare: (AppEntry *) other {
	return [[self name] localizedCaseInsensitiveCompare: [other name]];
}

- (BOOL)addChildEntry: (AppEntry *) entry {
	if (!childEntries)
		return NO;
	[childEntries addObject: entry];
	[childEntries sortUsingSelector: @selector(compare:)];
	return YES;
}

- (AppEntry *)childDirectoryEntryWithName: (NSString *) str createIfNotPresent: (BOOL) flag {
	AppEntry      *childEntry = nil;
	for (AppEntry *entry in childEntries) {
		if ([[entry name] isEqualToString: str] && ![entry isLeaf]) {
			childEntry = (AppEntry *)entry;
			break;
		}
	}
	if (!childEntry && flag && !isLeaf) {
		childEntry = [[AppEntry alloc] initWithURL: [NSURL URLWithString: [[[self pathWithName] stringByAppendingPathComponent: str] stringByAppendingString: @"/"]]];
		[self addChildEntry: childEntry];
	}
	return childEntry;
}

- (BOOL)addToRootEntry: (AppEntry *) rootEntry {
	AppEntry      *directoryEntry = rootEntry;
	NSArray       *components     = [appURL pathComponents];
	for (NSString *component in components) {
		if (![@"/" isEqualToString: component])
			directoryEntry = [directoryEntry childDirectoryEntryWithName: component createIfNotPresent: YES];
	}
	return directoryEntry ? [directoryEntry addChildEntry: self] : NO;
}

- (BOOL)setAttribute: (NSString *) xAttribute value: (NSString *) xValue {
	BOOL ok = [xattr setAttribute: xAttribute value: xValue];
	return ok;
}

- (BOOL)hasAttribute: (NSString *) string {
	id result = [xattr hasKey: string];
	if (result)
		return YES;
	else
		return NO;
}

- (BOOL)deleteAttribute: (NSString *) string {
	BOOL ok = NO;
	if ([self hasAttribute: string])
		ok = [xattr deleteAttribute: string];
	return ok;
}

- (void)revertIcon {
	iconImage = originalImage;
}

- (void)badgeAsNoAccess {
    // Setup for the composite image with size same as the current icon
    NSPoint point = {0.0, 0.0};
	NSSize currentSize = [iconImage size];
	NSRect currentRect = {point, currentSize};
        
    // setup the badge image and size
	NSBundle *mb            = [NSBundle mainBundle];
	NSURL    *badgeImageURL = [mb URLForResource: @"red-lock" withExtension: @"png"];
	NSImage  *badgeImage    = [[NSImage alloc] initWithContentsOfURL: badgeImageURL];
	NSPoint badgePoint = {0.0, 0.0};
    NSSize badgeSize = NSMakeSize([iconImage size].width / 4.0, [iconImage size].height / 4.0);
//	[badgeImage setSize: badgeSize];

    // draw current image badged
    NSImage  *currentImageBadged   = [[NSImage alloc] initWithSize:currentSize];
	[currentImageBadged lockFocus];
	[iconImage drawAtPoint: badgePoint fromRect:currentRect operation:NSCompositeSourceOver fraction: 1.0];
    [badgeImage drawInRect:NSMakeRect(0, 0, badgeSize.width, badgeSize.height)
                  fromRect:NSZeroRect // Draws full image.
                 operation:NSCompositeSourceOver
                  fraction:0.7];
	[currentImageBadged unlockFocus];
	iconImage = currentImageBadged;

    // draw original image badged
	NSImage *originalImageBadged = [[NSImage alloc] initWithSize:currentSize];
	[originalImageBadged lockFocus];
	[originalImage drawAtPoint: badgePoint fromRect:currentRect operation:NSCompositeSourceOver fraction: 1.0];
    [badgeImage drawInRect:NSMakeRect(0, 0, badgeSize.width, badgeSize.height)
                  fromRect:NSZeroRect // Draws full image.
                 operation:NSCompositeSourceOver
                  fraction:0.7];
	[originalImageBadged unlockFocus];
	originalImage = originalImageBadged;
    
    // set dictionary with badge version
	[iconDictionary setObject: iconImage forKey: KEY_IMAGE];
}

@end
