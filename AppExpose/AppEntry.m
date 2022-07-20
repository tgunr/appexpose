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
#import "AppDelegate.h"
#import "ImageReducer.h"

@interface NSImage (Dump)
- (void) dump;
@end

@implementation NSImage (Dump)

- (void) dump {
    NSBitmapImageRep *imgRep = (NSBitmapImageRep *)[[self representations] objectAtIndex: 0];
    NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
    [data writeToFile:@"/tmp/image.png" atomically:NO];
}

@end

@implementation AppEntry {
}

@synthesize isLeaf;
@synthesize isApp;
@synthesize canAccess;
@synthesize hasCustomIcon;
@synthesize name;
@synthesize appURL;
@synthesize childEntries;
@synthesize iconImage;
@synthesize originalImage;
@synthesize iconDictionary;
@synthesize isFolder;
@synthesize attributes;
@synthesize xattr;
@synthesize hasMyCustomIcon;
@synthesize skipDescendents;

+ (AppEntry *) rootEntry {
    return [[self alloc] initRootWithURL:[NSURL fileURLWithPath:@"/"]];
}

- (AppEntry *) initRootWithURL:(NSURL *) url {
    self = [super init];
    if (self) {
        appURL         = [url copy];
        isLeaf         = YES;
        isApp          = NO;
        name           = [[url lastPathComponent] copy];
        originalImage  = [[NSWorkspace sharedWorkspace] iconForFile:[appURL path]];
        iconImage      = originalImage;
        iconDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    iconImage, KEY_IMAGE,
                                                    name, KEY_NAME,
                                                    nil];
    }
    return self;
}

- (void) drawImage:(NSImage *) image withFrame:(NSRect) imageFrame {
    // [super drawImage:image withFrame:imageFrame inView:controlView];

    [NSGraphicsContext saveGraphicsState];

    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:5 yRadius:5];
    [path addClip];

    //set the size
    [image setSize:imageFrame.size];

    //draw the image
    [image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES
                hints:nil];

    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSBezierPath *path;
	NSColor *color;
	CGFloat stroke;
	
	// Box
	
    stroke = dirtyRect.size.width / 10.0;
    path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:stroke yRadius:stroke];
	color = [NSColor colorWithCalibratedRed:(CGFloat)0.8 green:(CGFloat)0.8 blue:(CGFloat)0.8 alpha:(CGFloat)1.0];
	[color setStroke];
	[path setLineWidth:stroke];
	[path setLineCapStyle:NSSquareLineCapStyle];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[path addClip];
	[path stroke];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (NSImage *) composeIcons {
    NSInteger numImages = [childEntries count];
    NSSize resultImageSize = NSMakeSize(ICON_SIZE, ICON_SIZE);
    NSImage *resultImage = [[NSImage alloc] initWithSize:resultImageSize];

    if (numImages > 1) {
        NSBundle *mb            = [NSBundle mainBundle];
        NSURL    *bgImageURL = [mb URLForResource:@"default" withExtension:@"png"];
        NSImage  *bgImage    = [[NSImage alloc] initWithContentsOfURL:bgImageURL];

        NSSize  littleIconSize = NSMakeSize((resultImageSize.width / 4.0), (resultImageSize.height / 4.0) );
        [resultImage lockFocus];
        [bgImage setSize:NSMakeSize(resultImageSize.width - 64, resultImageSize.height - 64)];
        [bgImage drawAtPoint:NSMakePoint(32.0, 32.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:.8];
        [self drawRect:NSMakeRect(0.0, 0.0, ICON_SIZE, ICON_SIZE)];
        int i, j;
        long count = MIN(9, numImages);
        BOOL stop = NO;
        NSPoint point;
//        CGFloat offset = resultImageSize.width / 8.0;
        CGFloat offset = resultImageSize.width * 0.64065;
        point.y = offset;
        PMLOG_DEBUG(@"name: %@ images: %d",name, numImages);

        for (i = 0; i < 3; i++) {
            point.x = offset;
            for (j=0; j < 3; j++) {
                AppEntry *entry          = [childEntries objectAtIndex:(i*3)+j];
                NSImage  *imageToCompose = [[entry iconImage] copy];
                [imageToCompose setSize:littleIconSize];
                PMLOG_DEBUG(@"point: %f,%f", point.x, point.y);
                [imageToCompose drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
                count--;
                if (count == 0) {
                    stop = YES;
                    break;
                }
                point.x = (point.x - 256) - 32;
            }
            if (stop) {
                break;
            }
            point.y = (point.y - 256) - 32;
        }
        [resultImage unlockFocus];
        ImageReducer *reducer = [[ImageReducer alloc] init];
        [reducer setInputImage:[resultImage copy]];
        [reducer setMaxPixelsWide: 512];
        [reducer setMaxPixelsHigh: 512];
        [reducer setScalesImage:YES];
        [reducer setSharpensImage:NO];
        [reducer setDrawBorder:NO];
        [reducer setAddsShadow:NO];
        NSBitmapImageRep *reduced = [reducer outputBitmapImageRep];
        [resultImage addRepresentation:reduced];

        [reducer setMaxPixelsWide: 256];
        [reducer setMaxPixelsHigh: 256];
        reduced = [reducer outputBitmapImageRep];
        [resultImage addRepresentation:reduced];

        [reducer setMaxPixelsWide: 128];
        [reducer setMaxPixelsHigh: 128];
        reduced = [reducer outputBitmapImageRep];
        [resultImage addRepresentation:reduced];

        [reducer setMaxPixelsWide: 64];
        [reducer setMaxPixelsHigh: 64];
        reduced = [reducer outputBitmapImageRep];
        [resultImage addRepresentation:reduced];

        [reducer setMaxPixelsWide: 32];
        [reducer setMaxPixelsHigh: 32];
        reduced = [reducer outputBitmapImageRep];
        [resultImage addRepresentation:reduced];

    } else {
        AppEntry *entry          = [childEntries objectAtIndex:0];
        resultImage = [[entry iconImage] copy];
    }
    return resultImage;
}

- (AppEntry *) initWithURL:(NSURL *) url {
    self = [super init];
    if (self) {
        NSError       *error;
        NSFileManager *fm = [[NSFileManager alloc] init];
        appURL        = [url copy];
        attributes    = [fm attributesOfItemAtPath:[url path] error:&error];
        xattr         = [[XATTR alloc] initWithURL:url options:nofollow];
        isLeaf        = [self isALeaf:url];
        isFolder      = [self isAFolder:url];
        hasCustomIcon = [self hasACustomIcon];
        isApp         = [self isAnApp:url];
        canAccess     = [self userCanAccess];
        name          = [[url lastPathComponent] copy];
        if (isFolder && [self hasMyCustomIcon]) {
            originalImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
        } else {
            originalImage = [[NSWorkspace sharedWorkspace] iconForFile:[appURL path]];
        }
        [originalImage setSize:NSMakeSize(ICON_SIZE, ICON_SIZE)];
        iconImage      = originalImage;
        if (isApp) {
            isLeaf = NO;
        } else {
            childEntries = [[NSMutableArray alloc] init];
            if (isFolder && [self isNotSpecial]) {
                [self scanURLForIcons:url forEntry:self];
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
    return self;
}

- (BOOL)hasMyCustomIcon {
    return [xattr hasAttribute:CUSTOM_ICON_ID]; 
}

- (BOOL) isNotSpecial {
    NSArray *specialNames = [NSArray arrayWithObjects:@"Utilities", nil];
    BOOL result = [specialNames containsObject:name];
    return !result;
}

- (BOOL) shouldSkipDescendents {
    BOOL result = isFolder && [childEntries count] > 0;
    return result;
}

- (void) scanURLForIcons:(NSURL *) directoryToScan forEntry:(AppEntry *) appEntry {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *fileKeys = [NSArray arrayWithObjects:NSURLIsPackageKey, nil];
    NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:directoryToScan
                                    includingPropertiesForKeys:fileKeys
                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                  errorHandler:nil];    
    for (NSURL *theURL in dirEnumerator) {
        
        // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        // Retrieve whether a directory. From NSURLIsDirectoryKey, also
        // cached during the enumeration.
        NSNumber *isAFolder;
        [theURL getResourceValue:&isAFolder forKey:NSURLIsDirectoryKey error:NULL];
        
        NSNumber *isSymLink;
        [theURL getResourceValue:&isSymLink forKey:NSURLIsSymbolicLinkKey error:NULL];
        
        NSNumber *isPackage;
        [theURL getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
        
        NSImage *customIcon;
        [theURL getResourceValue:&customIcon forKey:NSURLCustomIconKey error:NULL];
        
        // Ignore files under the app directory
        if ([isAFolder boolValue]) {
            if ([isPackage boolValue]) {
                AppEntry *entry = [[AppEntry alloc] initWithURL: theURL];
                if ([entry isApp]) {
                    PMLOG(2, @"adding: %@", theURL);
                    if ([appEntry addChildEntry:entry]) {
                        [dirEnumerator skipDescendents];
                    }
                } else
                    [dirEnumerator skipDescendents];
            }
            if ([dirEnumerator level] > MAX_LEVEL) {
                [dirEnumerator skipDescendents];
            }
        }
    }
}

- (BOOL) isALeaf:(NSURL *) url {
    NSString *fileType = [attributes objectForKey:NSFileType];
    if ([fileType isEqualToString:NSFileTypeDirectory])
        return NO; // folders are not leafs
    if ([fileType isEqualToString:NSFileTypeSymbolicLink])
        return NO; // symlinks can't be a leaf for now
    if ([[url pathExtension] isEqualToString:@"app"])
        return NO; // nor are Apps
    return YES;
}

- (BOOL) isAFolder:(NSURL *) url {
    NSString      *fileType       = [attributes objectForKey:NSFileType];
    if ([fileType isEqualToString:NSFileTypeSymbolicLink])
        return NO; // symlinks can't be a folder for now
    return [fileType isEqualToString:NSFileTypeDirectory] ? YES : NO;
}

- (BOOL) isAnApp:(NSURL *) url {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    BOOL result = [ws isFilePackageAtPath:[url path]];
    return result;
}

- (BOOL) userCanAccess {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL result1 = [fm isWritableFileAtPath:[appURL path]];
    NSError *error;
    BOOL result2 = [appURL checkResourceIsReachableAndReturnError:&error];
    if (!result1 || !result2) {
        PMLOG(2, @"no access: %@", appURL);
    }
    return result1 && result2;
}

- (BOOL)hasACustomIcon {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *customIconURL = [appURL URLByAppendingPathComponent: CUSTOM_ICON_NAME];
    BOOL result = [fm fileExistsAtPath:[customIconURL path]];
    return result;
}
    
- (NSString *) pathWithName {
    NSString *path = [[appURL path] stringByAppendingPathComponent:name];
    return isLeaf ? path : [path stringByAppendingString:@"/"];
}

- (NSComparisonResult) compare:(AppEntry *) other {
    return [[self name] localizedCaseInsensitiveCompare:[other name]];
}

- (BOOL) addChildEntry:(AppEntry *) entry {
    if (!childEntries)
        return NO;
    [childEntries addObject:entry];
    [childEntries sortUsingSelector:@selector(compare:)];
    return YES;
}

- (AppEntry *) childDirectoryEntryWithName:(NSString *) str createIfNotPresent:(BOOL) flag {
    AppEntry      *childEntry = nil;
    for (AppEntry *entry in childEntries) {
        if ([[entry name] isEqualToString:str] && ![entry isLeaf]) {
            childEntry = (AppEntry *) entry;
            break;
        }
    }
    if (!childEntry && flag && !isLeaf) {
        childEntry = [[AppEntry alloc] initWithURL:[NSURL URLWithString:[[[self pathWithName]
                                                                                stringByAppendingPathComponent:str]
                                                                                stringByAppendingString:@"/"]]];
        [self addChildEntry:childEntry];
    }
    return childEntry;
}

- (BOOL) addToRootEntry:(AppEntry *) rootEntry {
    AppEntry      *directoryEntry = rootEntry;
    NSArray       *components     = [appURL pathComponents];
    for (NSString *component in components) {
        if (![@"/" isEqualToString:component])
            directoryEntry = [directoryEntry childDirectoryEntryWithName:component createIfNotPresent:YES];
    }
    return directoryEntry ? [directoryEntry addChildEntry:self] : NO;
}

- (BOOL) setAttribute:(NSString *) xAttribute value:(NSString *) xValue {
    BOOL ok = [xattr setAttribute:xAttribute value:xValue];
    return ok;
}

- (BOOL) hasAttribute:(NSString *) string {
    BOOL result = [xattr hasAttribute:string];
    return result;
}

- (BOOL) deleteAttribute:(NSString *) string {
    BOOL ok = NO;
    if ([self hasAttribute:string])
        ok = [xattr deleteAttribute:string];
    return ok;
}

- (void) revertIcon {
    //    iconImage = originalImage;
}

- (void) badgeAsNoAccess {
    // Setup for the composite image with size same as the current icon
    NSPoint point       = {0.0, 0.0};
    NSSize  currentSize = [iconImage size];
    NSRect  currentRect = {point, currentSize};
    
    // setup the badge image and size
    NSBundle *mb            = [NSBundle mainBundle];
    NSURL    *badgeImageURL = [mb URLForResource:@"red-lock" withExtension:@"png"];
    NSImage  *badgeImage    = [[NSImage alloc] initWithContentsOfURL:badgeImageURL];
    NSPoint badgePoint = {0.0, 0.0};
    NSSize  badgeSize  = NSMakeSize([iconImage size].width / 4.0, [iconImage size].height / 4.0);
    //	[badgeImage setSize: badgeSize];
    
    // draw current image badged
    NSImage *currentImageBadged = [[NSImage alloc] initWithSize:currentSize];
    [currentImageBadged lockFocus];
    [iconImage drawAtPoint:badgePoint fromRect:currentRect operation:NSCompositeSourceOver fraction:1.0];
    [badgeImage drawInRect:NSMakeRect(0, 0, badgeSize.width, badgeSize.height)
                  fromRect:NSZeroRect // Draws full image.
                 operation:NSCompositeSourceOver
                  fraction:0.7];
    [currentImageBadged unlockFocus];
    iconImage = currentImageBadged;
    
    // draw original image badged
    NSImage *originalImageBadged = [[NSImage alloc] initWithSize:currentSize];
    [originalImageBadged lockFocus];
    [originalImage drawAtPoint:badgePoint fromRect:currentRect operation:NSCompositeSourceOver fraction:1.0];
    [badgeImage drawInRect:NSMakeRect(0, 0, badgeSize.width, badgeSize.height)
                  fromRect:NSZeroRect // Draws full image.
                 operation:NSCompositeSourceOver
                  fraction:0.7];
    [originalImageBadged unlockFocus];
    originalImage = originalImageBadged;
    
    // set dictionary with badge version
    [iconDictionary setObject:iconImage forKey:KEY_IMAGE];
}

- (void) badgeAsFolder {
    // Setup for the composite image with size same as the current icon
    NSPoint point       = {0.0, 0.0};
    NSSize  currentSize = [iconImage size];
    NSRect  currentRect = {point, currentSize};
    
    // setup the badge image and size
    NSBundle *mb            = [NSBundle mainBundle];
    NSURL    *badgeImageURL = [mb URLForResource:@"Folder" withExtension:@"png"];
    NSImage  *badgeImage    = [[NSImage alloc] initWithContentsOfURL:badgeImageURL];
    NSPoint badgePoint = {0.0, 0.0};
    NSSize  badgeSize  = NSMakeSize([iconImage size].width / 4.0, [iconImage size].height / 4.0);
    //	[badgeImage setSize: badgeSize];
    
    // draw current image badged
    NSImage *currentImageBadged = [[NSImage alloc] initWithSize:currentSize];
    [currentImageBadged lockFocus];
    [iconImage drawAtPoint:badgePoint fromRect:currentRect operation:NSCompositeSourceOver fraction:1.0];
    [badgeImage drawInRect:NSMakeRect(0, 0, badgeSize.width, badgeSize.height)
                  fromRect:NSZeroRect // Draws full image.
                 operation:NSCompositeSourceOver
                  fraction:0.7];
    [currentImageBadged unlockFocus];
    iconImage = currentImageBadged;
    
    // draw original image badged
    NSImage *originalImageBadged = [[NSImage alloc] initWithSize:currentSize];
    [originalImageBadged lockFocus];
    [originalImage drawAtPoint:badgePoint fromRect:currentRect operation:NSCompositeSourceOver fraction:1.0];
    [badgeImage drawInRect:NSMakeRect(0, 0, badgeSize.width, badgeSize.height)
                  fromRect:NSZeroRect // Draws full image.
                 operation:NSCompositeSourceOver
                  fraction:0.7];
    [originalImageBadged unlockFocus];
    originalImage = originalImageBadged;
    
    // set dictionary with badge version
    [iconDictionary setObject:iconImage forKey:KEY_IMAGE];
}

@end
