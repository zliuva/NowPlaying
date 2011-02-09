//
//  NowPlayingAppDelegate.h
//  NowPlaying
//
//  Created by fiNAL.Y on 11/02/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NowPlayingAppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
