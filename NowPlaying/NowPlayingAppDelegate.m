/*
 Copyright 2010 softboysxp.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  NowPlayingAppDelegate.m
//  NowPlaying
//
//  Created by fiNAL.Y on 11/02/09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NowPlayingAppDelegate.h"

#import "iTunes.h"

#import "Appirater.h"

#import "TrackInfoView.h"

#define SYSTEM_STATUS_BAR_HEIGHT ([[NSStatusBar systemStatusBar] thickness])
#define UPDATE_INTERVAL .3f

@interface NowPlayingAppDelegate(PRIVATE)

- (void)addStatusItem;

- (void)updateTrack;
- (void)updatePlayerState;

- (void)setTimer;
- (void)installTimer;
- (void)removeTimer;

- (void)loadPreferences;
- (void)savePreference;

- (BOOL)isLoginItem;
- (void)setLoginItem:(BOOL)shouldBeLoginItem;

@end

@implementation NowPlayingAppDelegate

@synthesize statusItem;
@synthesize trackInfoView;
@synthesize selfIcon;
@synthesize iTunesApp;

#pragma mark -
#pragma mark IBActions

- (IBAction)rate:(id)sender {
	if (!iTunesApp.isRunning) {
		return;
	}

	iTunesApp.currentTrack.rating = ((NSMenuItem *) sender).tag * 20;
}

- (IBAction)play:(id)sender {
	[iTunesApp playpause];
}

- (IBAction)previous:(id)sender {
	[iTunesApp previousTrack];
}

- (IBAction)next:(id)sender {
	[iTunesApp nextTrack];
}

- (IBAction)toggleDisplayOption:(id)sender {
	((NSMenuItem *) sender).state = !((NSMenuItem *) sender).state;
	[self savePreference];
	
	if (sender == showDurationMenuItem) {
		[self setTimer];
	}
	
	[self updateTrack];
	[self updatePlayerState];
}

- (IBAction)toggleOpenAtLogin:(id)sender {
	openAtLoginMenuItem.state = !openAtLoginMenuItem.state;
	[self setLoginItem:openAtLoginMenuItem.state];
}

#pragma mark -
#pragma mark Login Item Settings

- (BOOL)isLoginItem {
	NSMutableArray *loginItems = (NSMutableArray *)CFPreferencesCopyValue((CFStringRef)@"AutoLaunchedApplicationDictionary",
																		  (CFStringRef)@"loginwindow",
																		  kCFPreferencesCurrentUser,
																		  kCFPreferencesAnyHost); 	
	for (NSDictionary *dict in loginItems) {
		if ([[dict objectForKey:@"Path"] isEqualToString:[[NSBundle mainBundle] bundlePath]]) {
			CFRelease(loginItems);
			return YES;
		}
	}
	
	CFRelease(loginItems);
	return NO;
}

- (void)setLoginItem:(BOOL)shouldBeLoginItem {
	NSMutableArray *loginItems = (NSMutableArray *)CFPreferencesCopyValue((CFStringRef)@"AutoLaunchedApplicationDictionary",
																		  (CFStringRef)@"loginwindow",
																		  kCFPreferencesCurrentUser,
																		  kCFPreferencesAnyHost); 
	//loginItems = [[loginItems autorelease] mutableCopy]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"Hide", [[NSBundle mainBundle] bundlePath], @"Path", nil];
	
	[loginItems removeObject:dict]; //make sure it's not already in there
	if (shouldBeLoginItem) {
		[loginItems addObject:dict];
	}
	
	CFPreferencesSetValue((CFStringRef)@"AutoLaunchedApplicationDictionary",
						  loginItems,
						  (CFStringRef)@"loginwindow",
						  kCFPreferencesCurrentUser,
						  kCFPreferencesAnyHost);
	
	CFPreferencesSynchronize((CFStringRef)@"loginwindow", 
							 kCFPreferencesCurrentUser, 
							 kCFPreferencesAnyHost );
	CFRelease(loginItems);
}

#pragma mark -

- (void)loadPreferences {
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:YES], @"ShowArtwork",
							  [NSNumber numberWithBool:YES], @"ShowArtist",
							  [NSNumber numberWithBool:YES], @"ShowDuration",
							  nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	
	showArtworkMenuItem.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowArtwork"];
	showArtistMenuItem.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowArtist"];
	showDurationMenuItem.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowDuration"];
	
	openAtLoginMenuItem.state = [self isLoginItem];
}

- (void)savePreference {
	[[NSUserDefaults standardUserDefaults] setBool:showArtworkMenuItem.state forKey:@"ShowArtwork"];
	[[NSUserDefaults standardUserDefaults] setBool:showArtistMenuItem.state forKey:@"ShowArtist"];
	[[NSUserDefaults standardUserDefaults] setBool:showDurationMenuItem.state forKey:@"ShowDuration"];
}

- (void)addStatusItem {
	self.selfIcon = [NSImage imageNamed:@"Icon.icns"];
	selfIcon.scalesWhenResized = YES;
	selfIcon.size = NSMakeSize(SYSTEM_STATUS_BAR_HEIGHT, SYSTEM_STATUS_BAR_HEIGHT);
	
	self.trackInfoView = [[TrackInfoView alloc] initWithFrame:NSMakeRect(0, 0, SYSTEM_STATUS_BAR_HEIGHT, SYSTEM_STATUS_BAR_HEIGHT)];
	
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	statusItem.view = trackInfoView;
	statusItem.menu = mainMenu;
	statusItem.menu.delegate = trackInfoView;
	
	//trackInfoView.menu = mainMenu;
	trackInfoView.statusItem = statusItem;
	
	trackInfoView.artworkView.image = selfIcon;
}

#pragma mark -
#pragma mark iTunes monitoring

- (void)updateTrack {
	if (playerPaused) {
		return;
	}
	
	NSString *name = iTunesApp.currentTrack.name;
	NSString *artist = iTunesApp.currentTrack.artist;
	NSString *title;
	
	if (showArtistMenuItem.state && artist.length > 0) {
		title = [NSString stringWithFormat:@"%@ - %@", artist, name];
	} else {
		title = name;
	}
	
	[trackInfoView.titleField setStringValue:title];
	
	if (showArtworkMenuItem.state) {
		NSArray *artworks = iTunesApp.currentTrack.artworks;
		if (artworks && artworks.count >= 1) {
			iTunesArtwork *artwork = [artworks objectAtIndex:0];
			NSImage *image = [[NSImage alloc] initWithData:[artwork rawData]];
			[image setScalesWhenResized:YES];
			[image setSize:NSMakeSize(SYSTEM_STATUS_BAR_HEIGHT, SYSTEM_STATUS_BAR_HEIGHT)];
			
			trackInfoView.artworkView.image = image;
			[image release];
			
			NSBitmapImageRep *imgRep = [[image representations] objectAtIndex:0];
			NSData *data = [imgRep representationUsingType:NSPNGFileType properties: nil];
			[data writeToFile: @"/Users/final/test.png" atomically:YES];
		}
	} else {
		trackInfoView.artworkView.image = nil;
	}
	
	for (NSMenuItem *item in ratingMenuItem.submenu.itemArray) {
		item.state = (item.tag == iTunesApp.currentTrack.rating / 20);
	}
}

- (void)updatePlayerState {
	if (playerPaused) {
		return;
	}
	
	if (showDurationMenuItem.state) {
		NSInteger position = iTunesApp.playerPosition;
		NSString *duration = showDurationMenuItem.state ? [NSString stringWithFormat:@"(%02d:%02d)", position / 60, position % 60] : @"";
		[trackInfoView.durationField setStringValue:duration];
	} else {
		[trackInfoView.durationField setStringValue:@""];
	}
}

- (void)handleiTunesNotification:(NSNotification *)aNotification {
	NSString *playerState = [aNotification.userInfo objectForKey:@"Player State"];
	NSLog(@"%@", playerState);
	if (playerState &&
		([playerState isEqualToString:@"Stopped"] || [playerState isEqualToString:@"Paused"])) {
		
		playerPaused = YES;
		[self setTimer];
		
		trackInfoView.artworkView.image = selfIcon;
		[trackInfoView.titleField setStringValue:@""];
		[trackInfoView.durationField setStringValue:@""];
		
		[ratingMenuItem setEnabled:NO];
		playMenuItem.title = @"Play";
	} else {
		playerPaused = NO;
		[self setTimer];
		
		[ratingMenuItem setEnabled:YES];
		playMenuItem.title = @"Pause";
	
		[self updateTrack];
		[self updatePlayerState];
	}
}

- (void)handleTimer:(NSTimer *)aTimer {
	[self updatePlayerState];
}

- (void)setTimer {
	if (!playerPaused && showDurationMenuItem.state) {
		if (!updateTimer) {
			[self installTimer];
		}
	} else {
		[self removeTimer];
	}
}

- (void)installTimer {
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (void)removeTimer {
	[updateTimer invalidate];
	updateTimer = nil;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)showAbout:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}

#pragma mark -
#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self addStatusItem];
	[self loadPreferences];
	
	self.iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
														selector:@selector(handleiTunesNotification:)
															name:@"com.apple.iTunes.playerInfo"
														  object:nil];
	
	playerPaused = !iTunesApp.isRunning || iTunesApp.playerState == iTunesEPlSStopped || iTunesApp.playerState == iTunesEPlSPaused;
	
	[self updateTrack];
	[self updatePlayerState];
	
	[Appirater appLaunched:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	NSAlert *alert = [NSAlert alertWithMessageText:@"NowPlaying for Mac is already running"
									 defaultButton:@"OK"
								   alternateButton:nil
									   otherButton:nil
						 informativeTextWithFormat:@"NowPlaying for Mac is already running in the background.\nYou can access it from the status bar.\nYou can safely remove the dock icon if you wish to."];
	[alert runModal];
	
	return NO;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	
	[statusItem release];
	[trackInfoView release];

	[selfIcon release];
	
	[iTunesApp release];
	
	[updateTimer invalidate];
	
	[super dealloc];
}

@end
