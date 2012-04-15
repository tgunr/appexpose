//
//  AppEntry.h
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_IMAGE	@"icon"
#define KEY_NAME	@"name"

@interface AppEntry : NSObject {
    BOOL isLeaf;
    BOOL isApp;
	NSString *name;
	NSURL *appURL;
	NSMutableArray *childEntries;
	NSImage *iconImage;
    NSMutableDictionary *appDictionary;
}

@property(nonatomic, assign) BOOL isLeaf;
@property(nonatomic, assign) BOOL isApp;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSURL *appURL;
@property(nonatomic, strong) NSMutableArray *childEntries;
@property(nonatomic, strong) NSMutableDictionary *appDictionary;
@property(nonatomic, strong) NSImage *iconImage;

+ (AppEntry *)rootEntry;
- (BOOL)isLeaf:(NSURL *) url;
- (NSString *)pathWithName;
- (AppEntry *)initWithURL: (NSURL *) url;
- (BOOL)addToRootEntry: (AppEntry *) rootEntry;

@end
