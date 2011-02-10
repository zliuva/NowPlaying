/*
 Copyright 2010 softboysxp.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
