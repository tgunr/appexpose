/*
     File: MyViewController.m 
 Abstract: Controls the collection view of icons.
 */

#import "AppDelegate.h"
#import "MyViewController.h"
#import "MyWindowController.h"
#import "AppEntry.h"
#import <XATTR/xattr.h>

@implementation IconViewBox

// -------------------------------------------------------------------------------
//	hitTest:aPoint
// -------------------------------------------------------------------------------
@synthesize labelField;
@synthesize imageView;
@synthesize selected;

- (IconViewBox *)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
    
- (void)awakeFromNib {
    [[[[AppDelegate shared] myWindowController] viewController] setIconViewBox: self];
}

- (IconViewBox *)hitTest: (NSPoint) aPoint {
	// don't allow any mouse clicks for subviews in this NSBox
    [[AppDelegate shared] selectionChanged];
	return self;
}

- (void)drawRect1:(NSRect)dirtyRect 
{
    if (selected) {
        [[NSColor blueColor] set];
        NSRectFill([self bounds]);
    }
}

- (IBAction)iconSelected:(id)sender {
}
@end


@implementation MyScrollView

- (void)awakeFromNib {
	// set up the background gradient for this custom scrollView
	//backgroundGradient = [[NSGradient alloc] initWithStartingColor:
//			[NSColor colorWithDeviceRed: 0.349f green: 0.6f blue: 0.898f alpha: 0.0f]
//	                                                   endingColor: [NSColor colorWithDeviceRed: 0.349f green: 0.6f blue: .898f alpha: 0.4f]];
}

- (void)drawRect: (NSRect) rect {
	// draw our special background as a gradient
//	[backgroundGradient drawInRect: [self documentVisibleRect] angle: 90.0f];
}

@end

@implementation MyCollectionView

- (void)awakeFromNib {
    [self setSubviewSize: 128.0];
}

- (NSView *)hitTest: (NSPoint) aPoint {
    [[AppDelegate shared] selectionChanged];
    return nil;
}

- (void)didAddSubview:(IconViewBox *)subview {
    
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
    
}

-(void)setSubviewSize:(CGFloat)theSubviewSize {
    [self setMaxItemSize:NSMakeSize(theSubviewSize,theSubviewSize)];
    [self setMinItemSize:NSMakeSize(theSubviewSize,theSubviewSize)];
}

@end

@implementation MyCollectionViewItem

- (NSView *)hitTest: (NSPoint) aPoint {
    return nil;
}

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    [(IconViewBox*)[self view] setSelected:flag];
    [(IconViewBox*)[self view] setNeedsDisplay:YES];
}

@end

@implementation MyViewController {
	id appDirectory;
	AppEntry *rootEntry;

}

@synthesize iconViewBox;
@synthesize collectionViewItem;
@synthesize images;
@synthesize sortingMode;
@synthesize contentArray;
@synthesize scrollView;
@synthesize url;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    images = [[NSMutableArray alloc] init];
    contentArray = [[NSMutableArray alloc] init];

    [self addObserver:	self
           forKeyPath:@"url"
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
              context:NULL];

	// save this for later when toggling between alternate colors
	savedAlternateColors = [collectionView backgroundColors];

	[self setSortingMode: 0];        // icon collection in ascending sort order

	[collectionView setDraggingSourceOperationMask: NSDragOperationCopy forLocal: NO];
    NSIndexSet *indexes = [NSIndexSet indexSet];
    [collectionView setSelectionIndexes:indexes];
}

- (void)addEntries: (NSArray *) array {
	// This method is called on the main thread when a background read operation has entries to be added to the entry tree and displayed
	for (AppEntry *entry in array)
		[entry addToRootEntry: rootEntry];
}

- (void)setIcon: (AppEntry *)entry {
    if (entry != nil) {
        NSDictionary *iconDictionary = [entry iconDictionary];
        if (iconDictionary) {
            [arrayController addObject: iconDictionary];
            [contentArray addObject: entry];
            [self zoomChanged:DEFAULT_ICON_SIZE];
        }
        else {
            PMLOG(1, @"iconDictionary nil for: %@", [[entry appURL] path]);
        }
    }
}

- (void)setIcons: (NSMutableArray *) iconImages {
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (AppEntry  *entry in iconImages) {
        if (entry != nil) {
            if ([entry isFolder] && [[entry childEntries] count] == 1 )
                [entry badgeAsFolder];
                
            if (![entry canAccess] && ![entry isApp]) {
                [entry badgeAsNoAccess];
            }

            NSDictionary *iconDictionary = [entry iconDictionary];
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

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary*)change 
                       context:(void *)context
{
    [[[[NSApp delegate] myWindowController] progressIndicator] setHidden:NO];
    [[[[NSApp delegate] myWindowController] progressIndicator] startAnimation:self];

	// build our directory contents on a separate thread,
	// some portions are from disk which could get expensive depending on the size
	[NSThread detachNewThreadSelector:	@selector(collectFolders:)
                             toTarget:self		// we are the target
                           withObject:url];
}

- (void) collectFolders:(NSURL *) directoryToScan {
    @autoreleasepool {  
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSArray *fileKeys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLCustomIconKey, nil];
        NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:directoryToScan
                                        includingPropertiesForKeys:fileKeys
                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                      errorHandler:nil];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSURL *theURL in dirEnumerator) {
            
            // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
            NSString *fileName;
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            
            // Retrieve whether a directory. From NSURLIsDirectoryKey, also
            // cached during the enumeration.
            NSNumber *isFolder;
            [theURL getResourceValue:&isFolder forKey:NSURLIsDirectoryKey error:NULL];
            
            NSNumber *isSymLink;
            [theURL getResourceValue:&isSymLink forKey:NSURLIsSymbolicLinkKey error:NULL];
            
            NSNumber *isPackage;
            [theURL getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
            
            NSImage *customIcon;
            [theURL getResourceValue:&customIcon forKey:NSURLCustomIconKey error:NULL];
                        
            // Ignore files under the app directory
            if ([isFolder boolValue]) {
                if (![isPackage boolValue]) {
                    AppEntry *entry = [[AppEntry alloc] initWithURL: theURL];
                    if (![entry isApp]) {
                        PMLOG(2, @"adding: %@", theURL);
                        [self performSelectorOnMainThread:@selector(setIcon:) withObject:entry waitUntilDone:YES];
                        [tempArray addObject: entry];
                        [dirEnumerator skipDescendents];
                    }
                } else
                    [dirEnumerator skipDescendents];
            }
        }
        [[[[NSApp delegate] myWindowController] progressIndicator] stopAnimation:self];
        [[[[NSApp delegate] myWindowController] progressIndicator] setHidden:YES];
        [self performSelectorOnMainThread:@selector(setIcons:) withObject:tempArray waitUntilDone:YES];
        [collectionView setSelectionIndexes:[NSIndexSet indexSet]];
    }
}

- (void)readFromURL: (NSURL *) aURL {
	AppEntry       *entry;
	NSError        *error;
	NSMutableArray *entryArray = [NSMutableArray array];

	if (aURL) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *const path = [aURL path];
		NSArray *dirItems = [fm contentsOfDirectoryAtPath: path error: &error];

		int i = 0;
		for (NSString *item in dirItems) {
			i++;
			NSURL *itemURL = [aURL URLByAppendingPathComponent: item];
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
			NSURL *aurl = [temporaryDirectoryURL URLByAppendingPathComponent: [NSString stringWithFormat: @"%@.tiff", name]];
			[urls addObject: aurl];
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
    // get the current scroll position of the document view
    NSPoint currentScrollPosition=[[scrollView contentView] bounds].origin;
    NSIndexSet *indexes = [collectionView selectionIndexes];
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (AppEntry  *entry in contentArray) {
		if (entry != nil) {
			NSMutableDictionary *iconDictionary = [entry iconDictionary];
			if (iconDictionary) {
				NSImage *original = [entry originalImage];
				NSImage *custom  = [entry iconImage];
				if (custom == original)
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
    [collectionView setSelectionIndexes:indexes];
    [collectionView setSelectable:NO];
     // restore the scroll location
     [[scrollView documentView] scrollPoint:currentScrollPosition];
}

- (void)showAfterAppearance {
    // get the current scroll position of the document view
    NSPoint currentScrollPosition=[[scrollView contentView] bounds].origin;
    NSIndexSet *indexes = [collectionView selectionIndexes];
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (AppEntry  *entry in contentArray) {
		if (entry != nil) {
			NSDictionary *iconDictionary = [entry iconDictionary];
			[tempArray addObject: iconDictionary];
		}
	}
	[self setImages: tempArray];
    [collectionView setSelectionIndexes:indexes];
    [collectionView setSelectable:YES];

    // restore the scroll location
    [[scrollView documentView] scrollPoint:currentScrollPosition];
}

- (BOOL)askPermission: (NSURL *)url {
    return NO;
}

- (void)applyIcons {
    NSMutableArray *tempContentArray = [[NSMutableArray alloc] init];
    NSIndexSet *indexes = [collectionView selectionIndexes];
    if ([indexes count]) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [tempContentArray addObject:[contentArray objectAtIndex:idx]];
        }];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (AppEntry  *entry in tempContentArray) {
            if (entry != nil) {
                if ([entry canAccess]) {
                    NSMutableDictionary *iconDictionary = [entry iconDictionary];
                    if (iconDictionary) {
                        NSImage *original = [entry originalImage];
                        NSImage *current  = [entry iconImage];
                        if (current != original) {
                            PMLOG(1, @"Setting icon on: %@", [entry appURL]);
                            [tempArray addObject: entry];
                        }
                    } else 
                        PMLOG(1, @"iconDictionary nil for: %@", [[entry appURL] path]);
                } else
                    PMLOG(1, @"Skipping non-accessible url: %@", [[entry appURL] path]);
            }
        }
        NSWorkspace    *ws        = [NSWorkspace sharedWorkspace];
        for (AppEntry  *entry in tempArray) {
            NSURL *aURL = [entry appURL];
            BOOL ok = [entry setAttribute: CUSTOM_ICON_ID value: @""];
            if (!ok) {
                NSError *error = [[entry xattr] resultError];
                if ([error code] == 13) {
                    // Show ask permission
                    ok = [self askPermission: [entry appURL]];
                }
                [entry deleteAttribute: CUSTOM_ICON_ID];
            }
            ok = [ws setIcon: [entry iconImage] forFile: [aURL path] options: 0];
            if (!ok) {
                PMERR(1, @"Failed to set icon on: %@", url);
            }
        }
    }
    indexes = [NSIndexSet indexSet];
    [collectionView setSelectionIndexes:indexes];
}


- (void)removeIcons {
    NSMutableArray *tempContentArray = [[NSMutableArray alloc] init];
    
    NSIndexSet *indexes = [collectionView selectionIndexes];
    if ([indexes count]) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [tempContentArray addObject:[contentArray objectAtIndex:idx]];
        }];
        for (AppEntry *entry in tempContentArray) {
            NSURL *aURL = [entry appURL];
            BOOL hasCustomIcon = [entry hasAttribute: CUSTOM_ICON_ID];
            if (hasCustomIcon) {
                PMLOG(1, @"removing CustomIcon: %@", aURL);
                NSURL         *customIconURL = [aURL URLByAppendingPathComponent: CUSTOM_ICON_NAME];
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
                        NSLog(@"Error: %@", error);
                    }
                    
                }
                
            }
        }
    }
    indexes = [NSIndexSet indexSet];
    [collectionView setSelectionIndexes:indexes];
}

- (NSArray *)selectedIcons {
    NSMutableArray *tempContentArray = [[NSMutableArray alloc] init];
    NSIndexSet *indexes = [collectionView selectionIndexes];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [tempContentArray addObject:[contentArray objectAtIndex:idx]];
    }];
    return tempContentArray;
}

- (void)selectAll: (id)sender {
    NSRange range = {0, [contentArray count]};
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: range];
    [collectionView setSelectionIndexes:indexes];
    
}

- (void)selectNone: (id)sender {
    NSIndexSet *indexes = [NSIndexSet indexSet];
    [collectionView setSelectionIndexes:indexes];
}

- (void) zoomChanged: (CGFloat) newValue {
//    NSSize newSize = NSMakeSize(newValue, newValue);
//    NSRect newRect = NSMakeRect(0.0, 0.0, (newValue + 20), (newValue + 42) );
                                
//    NSArray *views = [collectionView subviews];
//    NSView *item = [views objectAtIndex:0];
//    PMLOG(1,@"frame: %f %f", item.frame.size.width, item.frame.size.height);
//    PMLOG(1,@"bounds: %f %f", item.bounds.size.width, item.bounds.size.height);

//    [collectionView setSubviewSize:newValue];
        [collectionView setMaxItemSize:NSMakeSize(newValue,newValue)];
        [collectionView setMinItemSize:NSMakeSize(newValue,newValue)];
    

    //    for (IconViewBox *box in views) {
//        [[box imageView] setFrameSize:newSize];
//        [box setFrameSize:newSize];
//    }
    
//	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//	for (AppEntry  *entry in contentArray) {
//		if (entry != nil) {
//			NSDictionary *iconDictionary = [entry iconDictionary];
//			if (iconDictionary) {
//                [[iconDictionary objectForKey:KEY_IMAGE] setSize:newSize];
//				[[entry iconImage] setSize:newSize];
//				[[entry originalImage] setSize:newSize];
//                [tempArray addObject: iconDictionary];
//			}
//			else {
//				PMLOG(1, @"iconDictionary nil for: %@", [[entry appURL] path]);
//			}
//		}
//	}
//	[self setImages: tempArray];
//    [[collectionViewItem view] display];
}

@end
