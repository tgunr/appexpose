/*
     File: MyViewController.h 
 Abstract: Controls the collection view of icons.
 */

#import <Cocoa/Cocoa.h>

@interface IconViewBox : NSBox
@property (strong) IBOutlet NSTextField *labelField;
@property (strong) IBOutlet NSImageView *imageView;
@property (readwrite) BOOL selected;

- (IBAction)iconSelected:(id)sender;

@end

@interface MyScrollView : NSScrollView {
	NSGradient *backgroundGradient;
}
@end

@interface MyCollectionView : NSCollectionView
@end

@interface MyCollectionViewItem : NSCollectionViewItem

@end


@interface MyViewController : NSViewController <NSCollectionViewDelegate> {
	IBOutlet NSCollectionView *collectionView;
	IBOutlet NSArrayController *arrayController;
    IBOutlet MyScrollView *scrollView;
    
    NSCollectionViewItem *collectionViewItem;
    IconViewBox *iconViewBox;
    
	NSMutableArray             *images;
	NSMutableArray             *contentArray;
	NSUInteger sortingMode;
	NSArray *savedAlternateColors;
    NSURL						*url;

}

@property(nonatomic, strong) IconViewBox *iconViewBox;
@property(nonatomic, strong) IBOutlet MyScrollView *scrollView;
@property(retain) NSMutableArray *images;
@property(nonatomic, assign) NSUInteger sortingMode;
@property(nonatomic, strong) NSMutableArray *contentArray;
@property(nonatomic, strong) IBOutlet NSCollectionViewItem *collectionViewItem;
@property (readwrite, retain) NSURL *url;

- (void)showBeforeAppearance;

- (void)showAfterAppearance;

- (void)setIcons: (NSMutableArray *) iconImages;

- (void)applyIcons;

- (void)removeIcons;

- (NSArray *)selectedIcons;

- (void)selectAll: (id)sender;
- (void)selectNone: (id)sender;

- (void) zoomChanged: (CGFloat) newValue;

@end
