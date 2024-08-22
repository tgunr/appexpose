//
//  IconViewBox.h
//  AppExposeC
//
//  Created by Dave Carlton on 8/29/22.
//

#import <Cocoa/Cocoa.h>

#ifndef IconViewBox_h
#define IconViewBox_h

@interface IconViewBox : NSBox
@property (strong) IBOutlet NSTextField *labelField;
@property (strong) IBOutlet NSImageView *imageView;
@property (readwrite) BOOL selected;

- (IBAction)iconSelected:(id)sender;

@end



#endif /* IconViewBox_h */
