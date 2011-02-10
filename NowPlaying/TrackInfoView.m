/*
 Copyright 2010 softboysxp.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  TrackInfoView.m
//  NowPlaying
//
//  Created by fiNAL.Y on 11/02/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackInfoView.h"

#import <QuartzCore/QuartzCore.h>

#define SYSTEM_STATUS_BAR_HEIGHT ([[NSStatusBar systemStatusBar] thickness])

// speed in pixel(s)/sec

#define SCROLLING_SPEED 30
#define RESIZE_SPEED 150

@interface TrackInfoView(PRIVATE)

- (void)updateView;
- (void)scrollTitle;

@end

@implementation TrackInfoView

@synthesize maximumWidth;
@synthesize artworkView, titleField, durationField;
@synthesize statusItem;

#pragma -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([[change objectForKey:NSKeyValueChangeNewKey] isEqualTo:[change objectForKey:NSKeyValueChangeOldKey]]) {
		return;
	}
	
	[self updateView];
}

- (void)updateView {
	[durationField sizeToFit];
	[titleField sizeToFit];
	
	// reset frames
	NSRect frame;
	
	// set empty fields to 0 width
	if (!artworkView.image) {
		frame = artworkView.frame;
		frame.size.width = 0;
		artworkView.frame = frame;
	} else {
		frame = artworkView.frame;
		frame.size.width = 22;
		artworkView.frame = frame;
	}
	
	if (!titleField.stringValue ||
		[titleField.stringValue length] == 0) {
		frame = titleField.frame;
		frame.size.width = 0;
		titleField.frame = frame;
	}
	
	if (!durationField.stringValue ||
		[durationField.stringValue length] == 0) {
		frame = durationField.frame;
		frame.size.width = 0;
		durationField.frame = frame;
	}
	
	frame = titleField.frame;
	frame.origin.y = (SYSTEM_STATUS_BAR_HEIGHT - frame.size.height) / 2;
	titleField.frame = frame;
	
	frame = titleFieldClippingView.frame;
	frame.origin.x = artworkView.frame.size.width;
	frame.size.width = MIN(titleField.frame.size.width, maximumWidth - artworkView.frame.size.width - durationField.frame.size.width);
	titleFieldClippingView.frame = frame;
	
	frame = durationField.frame;
	frame.origin.x = artworkView.frame.size.width + titleFieldClippingView.frame.size.width;
	frame.origin.y = (SYSTEM_STATUS_BAR_HEIGHT - frame.size.height) / 2;
	durationField.frame = frame;
	
	frame = self.frame;
	frame.size.width = artworkView.frame.size.width + titleFieldClippingView.frame.size.width + durationField.frame.size.width;
	CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"frameSize"];
	resizeAnimation.duration = fabs(frame.size.width - self.frame.size.width) / RESIZE_SPEED;
	resizeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	self.animations = [NSDictionary dictionaryWithObject:resizeAnimation forKey:@"frameSize"];
	[[self animator] setFrame:frame];
	
	if (fabs(titleFieldClippingView.frame.size.width - titleField.frame.size.width) > 5) {
		if (!isScrolling) {
			[self scrollTitle];
		}
	} else {
		// reset origin and remove animation
		CAAnimation *currentAnimation = [titleField animationForKey:@"frameOrigin"];
		currentAnimation.duration = 0;
		currentAnimation.repeatCount = 0;
		titleField.animations = [NSDictionary dictionaryWithObject:currentAnimation forKey:@"frameOrigin"];
		
		NSRect frame = titleField.frame;
		frame.origin.x = 0;
		[[titleField animator] setFrame:frame];
		
		isScrolling = NO;
	}
}

- (void)scrollTitle {
	isScrolling = YES;
	
	// create a "loop"
	NSRect oldFrame = titleField.frame;
	[self removeObserver:self forKeyPath:@"titleField.stringValue"];
	[titleField setStringValue:[NSString stringWithFormat:@"%@    %@", titleField.stringValue, titleField.stringValue]];
	[titleField sizeToFit];
	[self addObserver:self forKeyPath:@"titleField.stringValue" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
	NSRect frame = titleField.frame;
	
	CABasicAnimation *scrollAnimation = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];
	scrollAnimation.duration = fabs(frame.size.width - oldFrame.size.width) / SCROLLING_SPEED;
	scrollAnimation.repeatCount = HUGE_VAL;
	//scrollAnimation.autoreverses = YES;
	
	titleField.animations = [NSDictionary dictionaryWithObject:scrollAnimation forKey:@"frameOrigin"];
	
	frame.origin.x = - (frame.size.width - oldFrame.size.width);//titleFieldClippingView.frame.size.width - titleField.frame.size.width;
	[[titleField animator] setFrame:frame];
}

#pragma -
#pragma NSView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		artworkView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, SYSTEM_STATUS_BAR_HEIGHT, SYSTEM_STATUS_BAR_HEIGHT)];
		
		durationField = [[NSTextField  alloc] initWithFrame:NSZeroRect];
		titleField = [[NSTextField  alloc] initWithFrame:NSZeroRect];
		
		[durationField setEditable:NO];
		[durationField setBezeled:NO];
		[durationField setBackgroundColor:[NSColor clearColor]];
		[durationField setFont:[NSFont menuBarFontOfSize:0]];
		
		[titleField setWantsLayer:YES];
		[titleField setEditable:NO];
		[titleField setBezeled:NO];
		[titleField setBackgroundColor:[NSColor clearColor]];
		[titleField setFont:[NSFont menuBarFontOfSize:0]];
		
		titleFieldClippingView = [[NSView alloc] initWithFrame:NSMakeRect(artworkView.frame.size.width, 0, 0, SYSTEM_STATUS_BAR_HEIGHT)];
		
		[titleFieldClippingView addSubview:titleField];
		[self addSubview:artworkView];
		[self addSubview:titleFieldClippingView];
		[self addSubview:durationField];
		
		[self addObserver:self forKeyPath:@"artworkView.image" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"durationField.stringValue" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"titleField.stringValue" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
		
		if (maximumWidth <= 0) {
			maximumWidth = 300;
		}
    }
    
    return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"artworkView.image"];
	[self removeObserver:self forKeyPath:@"durationField.stringValue"];
	[self removeObserver:self forKeyPath:@"titleField.stringValue"];
	
	[statusItem release];
	
    [super dealloc];
}

#pragma -
#pragma Handling menu

- (void)drawRect:(NSRect)dirtyRect {
	[statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:isMenuShowing];
}

- (void)mouseDown:(NSEvent *)event {
	[statusItem popUpStatusItemMenu:statusItem.menu];
	[self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
	[self mouseDown:nil];
}

- (void)menuWillOpen:(NSMenu *)menu {
	isMenuShowing = YES;
	[self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
	isMenuShowing = NO;
	[self setNeedsDisplay:YES];
}

@end
