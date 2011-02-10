//
//  NowPlayingAppDelegate.h
//  NowPlaying
//
//  Created by fiNAL.Y on 11/02/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TrackInfoView;
@class iTunesApplication;

@interface NowPlayingAppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSStatusItem *statusItem;
	
	IBOutlet NSMenu *mainMenu;
	
	IBOutlet NSMenuItem *ratingMenuItem;
	IBOutlet NSMenuItem *playMenuItem;
	IBOutlet NSMenuItem *previousMenuItem;
	IBOutlet NSMenuItem *nextMenuItem;
	
	IBOutlet NSMenuItem *showArtworkMenuItem;
	IBOutlet NSMenuItem *showArtistMenuItem;
	IBOutlet NSMenuItem *showDurationMenuItem;
	
	IBOutlet NSMenuItem *openAtLoginMenuItem;
	
	TrackInfoView *trackInfoView;
	
	NSImage *selfIcon;
	
	iTunesApplication *iTunesApp;
}

@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) TrackInfoView *trackInfoView;
@property (nonatomic, retain) NSImage *selfIcon;
@property (nonatomic, retain) iTunesApplication *iTunesApp;

- (IBAction)rate:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;

- (IBAction)toggleDisplayOption:(id)sender;

- (IBAction)toggleOpenAtLogin:(id)sender;

- (IBAction)showAbout:(id)sender;

@end
