/*
 * ForgetMeNot
 * Copyright (C) 2006  Jim Fowler
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
 
#import <Cocoa/Cocoa.h>

@interface JFSafariPlugin : NSObject {
	NSMutableArray* closedWindows;
	IBOutlet NSMenu* fileMenuAdditions;
	NSString* closeTabString;
}

+ (void) load;
+ (JFSafariPlugin*) sharedInstance;

- (void)openBrowserWithURLs:(NSArray*)tabs;
- (void)openBrowserWithURLs:(NSArray*)tabs inDocument:(NSDocument*)document;

- (IBAction)unclose:(id)sender;

- (NSArray*)mostRecentlyClosedWindow;
- (void)rememberClosedWindow:(NSArray*)anArray;

- (NSString*)localizedCloseTabString;

- (BOOL)shouldReloadOnRelaunch;

- (BOOL)isLoaded;

@end
