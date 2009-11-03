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

#import "BrowserWindowController.h"
#import <WebKit/WebKit.h>
#import "JFSafariPlugin.h"

@implementation BrowserWindowController (JFSwizzle)

/* There will be some warnings when we compile this; we are missing the
implementations of _safari_... */

/* Answer the array of URLs loaded in the tabs of this window */
- (NSArray*)_jf_openedTabs
{
	NSMutableArray* tabs = [NSMutableArray array]; // for saving tabs
	
	// For each open tab...
	NSEnumerator* e = [[self orderedTabViewItems] objectEnumerator];
	NSTabViewItem* item;
	
	while( item = [e nextObject] ) {
		// If the tab currently has a URL loaded
		if ([[item webView] currentURL] != nil)
			// add the URL to our list for this window
			[tabs addObject: [[item webView] currentURL]];
	}
	
	return tabs;
}	
		
/* Swizzled windowShouldClose: */
- (BOOL)_jf_windowShouldClose:(id)sender
{
	// If Safari decides that we are about to close...
	if ([self _safari_windowShouldClose: sender]) {
		// Save the opened tabs...
		[[JFSafariPlugin sharedInstance] rememberClosedWindow:
			[self _jf_openedTabs]];
		
		// and close the window.
		return YES;
	}

	return NO;
}

- (void)_jf_windowWillClose:(id)sender
{
	[self _safari_windowWillClose: sender];
	
	return;
}


-(void)_jf_newTabWithURL:(NSURL*)url
{
	// Create a blank tab
	WebView* webView = [self createTab];

	// Load the requested URL into this tab
	[[webView mainFrame] loadRequest: [NSURLRequest requestWithURL: url]];
	
	// Get the BrowserTabViewItem related to the tab
	//NSEnumerator* e = [[[webView superview] tabViewItems] objectEnumerator];
	NSEnumerator* e = [[self orderedTabViewItems] objectEnumerator];
	NSTabViewItem* item;
	NSTabViewItem* theItem;
	
	while( item = [e nextObject] ) {
		if ([item webView] == webView) {
			theItem = item;
			break;
		}
	}
	
	// If we found a BrowserTabViewItem...
	if (theItem != nil) {
		// we can undo this new tab by closing the tab
		NSUndoManager* undoManager = [[self document] undoManager];
	
		[undoManager beginUndoGrouping];
		[undoManager setActionName:
			[[JFSafariPlugin sharedInstance] localizedCloseTabString]];
		[undoManager registerUndoWithTarget:self
								   selector:@selector(closeTab:)
									 object:theItem];
		[undoManager endUndoGrouping];
	}

	return;
}
	
/* Swizzled closeTab: */
- (BOOL)_jf_closeTab:(id)tab
{
	// we can unclose the tab by creating a new tab with the current URL
	NSUndoManager* undoManager = [[self document] undoManager];
	
	// NSLog( @"tab = %@\n", tab );
	
	[undoManager beginUndoGrouping];
	[undoManager setActionName:
		[[JFSafariPlugin sharedInstance] localizedCloseTabString]];
	[undoManager registerUndoWithTarget:self
							   selector:@selector(_jf_newTabWithURL:)
								 object:[[tab webView] currentURL]]; // [tab view] replaced with [tab webView]
	
	[undoManager endUndoGrouping];
	
	// swizzle the tab closed
	return [self _safari_closeTab: tab];
}

@end
