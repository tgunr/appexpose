//
//  main.m
//  AppExpose
//
//  Created by Dave Carlton on 1/5/12.
//  Copyright (c) 2012 PolyMicro Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMUtility/pmUtility.h"
int main(int argc, char *argv[])
{
    @autoreleasepool {
        PMLOG_SetVerbose(1);
        return NSApplicationMain(argc, (const char **)argv);
    }
}
