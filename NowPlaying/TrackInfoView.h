//
//  TrackInfoView.h
//  NowPlaying
//
//  Created by fiNAL.Y on 11/02/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TrackInfoView : NSView<NSMenuDelegate> {
@private
	NSImageView *artworkView;
	NSTextField *durationField;
	NSTextField *titleField;
	NSView *titleFieldClippingView;
	
	CGFloat maximumWidth;
	
	BOOL isScrolling;
	
	NSStatusItem *statusItem;
	
	BOOL isMenuShowing;
}

@property (nonatomic, assign) CGFloat maximumWidth;

@property (nonatomic, readonly) NSImageView *artworkView;
@property (nonatomic, readonly) NSTextField *durationField;
@property (nonatomic, readonly) NSTextField *titleField;

@property (nonatomic, retain) NSStatusItem *statusItem;

- (void)updateView;

@end
