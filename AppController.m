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
 
#import "AppController.h"
#import <WebKit/WebKit.h>
#import "BrowserWindowController.h"
#import "JFSafariPlugin.h"

@implementation AppController  (JFSwizzle)

/* There will be some warnings when we compile this; we are missing the
   implementations of _safari_... */

////////////////////////////////////////////////////////////
// Swizzled application termination - save the tabs for next time
-(void)_jf_applicationWillTerminate:(id)fp8
{
	NSMutableArray* windows = [NSMutableArray array]; // for saving windows

	// For each open window...
	NSEnumerator* e = [[[NSDocumentController sharedDocumentController]
							documents] objectEnumerator];
	id document;
	
	while( document = [e nextObject] ) {
		BrowserWindowController* windowController =
			[[document windowControllers] objectAtIndex: 0];
		
		// Add this window to our list of windows
		[windows addObject: [windowController _jf_openedTabs]];
	}
	
	// Save the opened URLs in Safari's preferences
	NSData *windowData=[NSKeyedArchiver archivedDataWithRootObject:windows];
	[[NSUserDefaults standardUserDefaults] setObject:windowData
											  forKey:@"jfSavedWindowsAndTabs"];
			
	// Call Safari's method that we swizzled.
	[self _safari_applicationWillTerminate: fp8];
}


////////////////////////////////////////////////////////////
// Whether or not to obliterate the initial window
static BOOL firstWindow = YES;

////////////////////////////////////////////////////////////
// Swizzled file open
- (BOOL)_jf_application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	// Since we are opening a file, do not overwrite the first window Safari loads 
	firstWindow = NO;
	return [self _safari_application:theApplication openFile:filename];
}

////////////////////////////////////////////////////////////
// Swizzled URL open
- (void)_jf_handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)reply
{
	firstWindow = NO;
	return [self _safari_handleURLEvent:event withReplyEvent:reply];
}

////////////////////////////////////////////////////////////
// Swizzled application launch -- reload the tabs from last time
-(void)_jf_applicationDidFinishLaunching:(id)fp8
{
	// Call Safari's method that we swizzled.
	[self _safari_applicationDidFinishLaunching: fp8];

	// Abort if the user asked us not to reload the old windows and tabs
	if ([[JFSafariPlugin sharedInstance] shouldReloadOnRelaunch] == NO)
		return;
	
	// Load the URL data from Safari's preferences 
	NSData *windowData=[[NSUserDefaults standardUserDefaults]
		dataForKey:@"jfSavedWindowsAndTabs"];

	if (windowData != nil) {
		// Load the list of windows and tabs to open
		NSMutableArray* windows = (NSMutableArray*)[NSKeyedUnarchiver
			unarchiveObjectWithData:windowData];

		// For each window we want to recreate...
		NSEnumerator* windowEnumerator = [windows objectEnumerator];
		NSArray* tabs;

		while( tabs = [windowEnumerator nextObject] ) {
			// Load a browser with those tabs.
			if (firstWindow) {
				NSDocument* document =
					[[[NSDocumentController sharedDocumentController] documents]
						objectAtIndex: 0];
				[[JFSafariPlugin sharedInstance] openBrowserWithURLs: tabs
														  inDocument: document];
					
				firstWindow = NO;
			} else {
				[[JFSafariPlugin sharedInstance] openBrowserWithURLs: tabs];
			}
		}
	}

	return;
}

////////////////////////////////////////////////////////////
// Swizzled validation - validate our unclose menu item
-(BOOL)_jf_validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	// If we are asked to validate the unclose menu item...
	if ([anItem action] == @selector(unclose:)) {
		// Answer yes if the plugin has tabs we can resurrect
		if ([[JFSafariPlugin sharedInstance] mostRecentlyClosedWindow] != nil)
			return YES;
		else
			return NO;
	}
	
	// Otherwise ask Safari to validate the item for us
	return [self _safari_validateUserInterfaceItem: anItem];
}

@end
