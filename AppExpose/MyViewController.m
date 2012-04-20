/*
     File: MyViewController.m 
 Abstract: Controls the collection view of icons.
  
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

#import "AppDelegate.h"
#import "MyViewController.h"
#import "AppEntry.h"
#import <XATTR/xattr.h>

@implementation IconViewBox

// -------------------------------------------------------------------------------
//	hitTest:aPoint
// -------------------------------------------------------------------------------
- (NSView *)hitTest: (NSPoint) aPoint {
	// don't allow any mouse clicks for subviews in this NSBox
    [[AppDelegate shared] selectionChanged];
	return nil;
}

@end


@implementation MyScrollView

- (void)awakeFromNib {
	// set up the background gradient for this custom scrollView
	backgroundGradient = [[NSGradient alloc] initWithStartingColor:
			[NSColor colorWithDeviceRed: 0.349f green: 0.6f blue: 0.898f alpha: 0.0f]
	                                                   endingColor: [NSColor colorWithDeviceRed: 0.349f green: 0.6f blue: .898f alpha: 0.6f]];
}

- (void)drawRect: (NSRect) rect {
	// draw our special background as a gradient
	[backgroundGradient drawInRect: [self documentVisibleRect] angle: 90.0f];
}

@end


@implementation MyViewController {
	id appDirectory;
	AppEntry *rootEntry;
}

@synthesize collectionViewItem;
@synthesize images;
@synthesize sortingMode;
@synthesize contentArray;

- (void)awakeFromNib {
	// save this for later when toggling between alternate colors
	savedAlternateColors = [collectionView backgroundColors];

	[self setSortingMode: 0];        // icon collection in ascending sort order

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSSystemDomainMask, YES);
	appDirectory = [paths objectAtIndex: 0];
	if ([paths count] > 0) {
		appDirectory = [paths objectAtIndex: 0];
	}
	appDirectory = [appDirectory stringByAppendingString: @"/"];
#ifdef DEBUG
    appDirectory = @"/Users/davec/Applications/";
#endif
	NSURL *root = [NSURL fileURLWithPath: appDirectory];
	contentArray = [self gatherContents: root];
//    [self readFromURL:root];
//	[self originalCollection];

	[self setIcons: contentArray];
	[collectionView setDraggingSourceOperationMask: NSDragOperationCopy forLocal: NO];
    NSIndexSet *indexes = [NSIndexSet indexSet];
    [collectionView setSelectionIndexes:indexes];
}

- (void)addEntries: (NSArray *) array {
	// This method is called on the main thread when a background read operation has entries to be added to the entry tree and displayed
	for (AppEntry *entry in array)
		[entry addToRootEntry: rootEntry];
}

- (void)setIcons: (NSMutableArray *) iconImages {
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (AppEntry  *entry in iconImages) {
		if (entry != nil) {

			NSDictionary *iconDictionary = [entry appDictionary];
			if (iconDictionary) {
				[tempArray addObject: iconDictionary];
			}
			else {
				PMLOG(1, @"iconDictionary nil for: %@", [[entry appURL] path]);
			}
		}
	}
	[self setImages: tempArray];
}

// -------------------------------------------------------------------------------
//	gatherContents:inObject
//
//	Gathering the contents and their icons could be expensive.
//	This method is being called on a separate thread to avoid blocking the UI.
// -------------------------------------------------------------------------------
- (NSMutableArray *)gatherContents: (NSURL *) url {
	contentArray = [[NSMutableArray alloc] init];

	NSArray       *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [url path] error: nil];
	for (NSString *element in files) {
		// we need to reconstruct the full path of the object since 'directoryContentsAtPath' only gives us the object name
		NSString *pathStr = [[url path] stringByAppendingPathComponent: element];

		// examine if this object is invisible (don't include in the array)
		CFDictionaryRef values    = NULL;
		CFStringRef     attrs[1]  = {kLSItemIsInvisible};
		CFArrayRef      attrNames = CFArrayCreate(NULL, (const void **)attrs, 1, NULL);

		FSRef   fileRef;
		Boolean isDirectory;
		if (FSPathMakeRef((const UInt8 *)[pathStr fileSystemRepresentation], &fileRef, &isDirectory) == noErr) {
			if (LSCopyItemAttributes(&fileRef, kLSRolesViewer, attrNames, &values) == noErr) {
				if (values != NULL) {
					if (CFDictionaryGetValue(values, kLSItemIsInvisible) == kCFBooleanFalse) {
						// object is visible so add to our array
						AppEntry *entry = [[AppEntry alloc] initWithURL: [NSURL fileURLWithPath: pathStr]];
						[contentArray addObject: entry];
					}
				}
				CFRelease(values);
			}
		}
		CFRelease(attrNames);
	}
	return contentArray;
}

- (void)readFromURL: (NSURL *) url {
	AppEntry       *entry;
	NSError        *error;
	NSMutableArray *entryArray = [NSMutableArray array];

	if (url) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *const path = [url path];
		NSArray *dirItems = [fm contentsOfDirectoryAtPath: path error: &error];

		int i = 0;
		for (NSString *item in dirItems) {
			i++;
			NSURL *itemURL = [url URLByAppendingPathComponent: item];
			entry = [[AppEntry alloc] initWithURL: itemURL];
			[entryArray addObject: entry];
		}
		[self addEntries: entryArray];
		[self setIcons: entryArray];
	}
}

- (void)setSortingMode: (NSUInteger) newMode {
	sortingMode = newMode;
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
	                                            initWithKey: KEY_NAME ascending: (sortingMode == 0)
			                                       selector: @selector(caseInsensitiveCompare:)];
	[arrayController setSortDescriptors: [NSArray arrayWithObject: sort]];
}

// -------------------------------------------------------------------------------
//	collectionView:writeItemsAtIndexes:indexes:pasteboard
//
//	Collection view drag and drop
//  User must click and hold the item(s) to perform a drag.
// -------------------------------------------------------------------------------
- (BOOL)collectionView: (NSCollectionView *) cv writeItemsAtIndexes: (NSIndexSet *) indexes toPasteboard: (NSPasteboard *) pasteboard {
	NSMutableArray *urls                  = [NSMutableArray array];
	NSURL          *temporaryDirectoryURL = [NSURL fileURLWithPath: NSTemporaryDirectory() isDirectory: YES];
	[indexes enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
		NSDictionary *dictionary = [[cv content] objectAtIndex: idx];
		NSImage      *image      = [dictionary objectForKey: KEY_IMAGE];
		NSString     *name       = [dictionary objectForKey: KEY_NAME];
		if (image && name) {
			NSURL *url = [temporaryDirectoryURL URLByAppendingPathComponent: [NSString stringWithFormat: @"%@.tiff", name]];
			[urls addObject: url];
			[[image TIFFRepresentation] writeToURL: url atomically: YES];
		}
	}];
	if ([urls count] > 0) {
		[pasteboard clearContents];
		return [pasteboard writeObjects: urls];
	}
	return NO;
}


- (void)showBeforeAppearance {
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (AppEntry  *entry in contentArray) {
		if (entry != nil) {
			NSMutableDictionary *iconDictionary = [entry appDictionary];
			if (iconDictionary) {
				NSImage *original = [entry originalImage];
				NSImage *current  = [entry iconImage];
				if (current == original)
					[tempArray addObject: iconDictionary];
				else {
					NSMutableDictionary *newDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							                                                          original, KEY_IMAGE,
							                                                          [entry name], KEY_NAME,
							                                                          nil];
					[tempArray addObject: newDictionary];
				}
			}
			else {
				PMLOG(1, @"iconDictionary nil for: %@", [[entry appURL] path]);
			}
		}
	}
	[self setImages: tempArray];
    NSIndexSet *indexes = [NSIndexSet indexSet];
    [collectionView setSelectionIndexes:indexes];
}

- (void)setBeforeAppearance {
    
}
- (void)showAfterAppearance {
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (AppEntry  *entry in contentArray) {
		if (entry != nil) {
			NSDictionary *iconDictionary = [entry appDictionary];
			[tempArray addObject: iconDictionary];
		}
	}
	[self setImages: tempArray];
    NSIndexSet *indexes = [NSIndexSet indexSet];
    [collectionView setSelectionIndexes:indexes];
}

- (BOOL)askPermission: (NSURL *)url {
    return NO;
}

typedef void(^selectedContents)(NSUInteger idx, BOOL stop);

- (void)applyIcons {
    NSMutableArray *tempContentArray = [[NSMutableArray alloc] init];

    NSIndexSet *indexes = [collectionView selectionIndexes];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [tempContentArray addObject:[contentArray objectAtIndex:idx]];
    }];
    if ([indexes count]) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (AppEntry  *entry in tempContentArray) {
            if (entry != nil) {
                NSMutableDictionary *iconDictionary = [entry appDictionary];
                if (iconDictionary) {
                    NSImage *original = [entry originalImage];
                    NSImage *current  = [entry iconImage];
                    if (current != original) {
                        PMLOG(1, @"Setting icon on: %@", [entry appURL]);
                        [tempArray addObject: entry];
                    }
                }
            }
            else {
                PMLOG(1, @"iconDictionary nil for: %@", [[entry appURL] path]);
            }
        }
        NSWorkspace    *ws        = [NSWorkspace sharedWorkspace];
        for (AppEntry  *entry in tempArray) {
            NSURL *url = [entry appURL];
            BOOL ok = [entry setAttribute: CUSTOM_ICON_ID value: @""];
            if (!ok) {
                NSError *error = [[entry xattr] resultError];
                if ([error code] == 13) {
                    // Show ask permission
                    ok = [self askPermission: [entry appURL]];
                }
                [entry deleteAttribute: CUSTOM_ICON_ID];
            }
            ok = [ws setIcon: [entry iconImage] forFile: [url path] options: 0];
            if (!ok) {
                PMERR(1, @"Failed to set icon on: %@", url);
            }
        }
    }
}


- (void)removeIcons {
    NSMutableArray *tempContentArray = [[NSMutableArray alloc] init];
    
    NSIndexSet *indexes = [collectionView selectionIndexes];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [tempContentArray addObject:[contentArray objectAtIndex:idx]];
    }];
    if ([indexes count]) {
        for (AppEntry *entry in contentArray) {
            NSURL *url = [entry appURL];
            BOOL folder        = [entry isFolder];
            BOOL leaf          = [entry isLeaf];
            BOOL hasCustomIcon = [entry hasAttribute: CUSTOM_ICON_ID];
            if (hasCustomIcon) {
                PMLOG(1, @"removing CustomIcon: %@", url);
                NSURL         *customIconURL = [url URLByAppendingPathComponent: @"Icon\r"];
                NSFileManager *fm            = [NSFileManager defaultManager];
                BOOL ok = [fm fileExistsAtPath: [customIconURL path]];
                NSError *error;
                if (ok)
                    [fm removeItemAtURL: customIconURL error: &error];
                ok = [entry deleteAttribute: CUSTOM_ICON_ID];
                if (ok) {
                    [entry revertIcon];
                } else {
                    NSError *error = [[entry xattr] resultError];
                    if ([error code] == 13) {
                        // Show ask permission
                    } else {
                        NSLog(@"Error: @%", error);
                    }
                    
                }
                
            }
        }
    }
}

- (NSArray *)selectedIcons {
    NSMutableArray *tempContentArray = [[NSMutableArray alloc] init];
    
    NSIndexSet *indexes = [collectionView selectionIndexes];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [tempContentArray addObject:[contentArray objectAtIndex:idx]];
    }];
    return tempContentArray;
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
    
}



@end
