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
 
#import "JFSafariPlugin.h"
#import "AppController.h"
#import "BrowserWindowController.h"
#import <WebKit/WebKit.h>


@implementation JFSafariPlugin

/*
 * A special method called by SIMBL once the application has started and all classes are initialized.
 */
+ (void) load
{
	NSLog(@"ForgetMeNot installed.");
	
	[ForgetMeNotBrowserWindowController ForgetMeNot_load];
	[ForgetMeNotAppController ForgetMeNot_load];

	// Add menu item "Unclose" to the File menu, underneath "Close Window"
	[NSBundle loadNibNamed:@"MenuAdditions" owner:[JFSafariPlugin sharedInstance]];
	
	return;
}

- (NSString*)localizedCloseTabString
{
	return closeTabString;
}

// After having awoken from the nib, add localized menu items
- (void)awakeFromNib
{
	NSMenu* safariMenuBar = [[NSApplication sharedApplication] mainMenu];
	NSMenu* fileMenu = [[safariMenuBar itemAtIndex: 1] submenu];
	
	NSMenuItem* uncloseWindowMenuItem = [fileMenuAdditions itemAtIndex: 0];
	
	{
		NSEnumerator* itemEnumerator = [[fileMenu itemArray] objectEnumerator];
		NSMenuItem* item;
	
		while( item = [itemEnumerator nextObject] ) {
			if ([item action] == @selector(performClose:)) {
				int index = [fileMenu indexOfItem: item];
				[fileMenu insertItem: [uncloseWindowMenuItem copy]
							 atIndex: index + 1];
				break;
			}
		}
	}
	
	// Find the localized name of the close tab command
	NSEnumerator* itemEnumerator = [[fileMenu itemArray] objectEnumerator];
	NSMenuItem* item;
	
	while( item = [itemEnumerator nextObject] ) {
		if ([item action] == @selector(closeCurrentTab:)) {
			closeTabString = [item title];
			[closeTabString retain];
			break;
		}
	}
	
	// Store closed windows in a stack
	closedWindows = [NSMutableArray array];
	[closedWindows retain];
	
	return;
}

/*
 * @return the single static instance of the plugin object
 */
+ (JFSafariPlugin*) sharedInstance
{
        static JFSafariPlugin* plugin = nil;

        if (plugin == nil)
                plugin = [[JFSafariPlugin alloc] init];

        return plugin;
}

-(void)openBrowserWithURLs:(NSArray*)tabs inDocument:(NSDocument*)document
{
	if (document == nil) {
		NSError* error;
		document = [[NSDocumentController sharedDocumentController]
		openUntitledDocumentAndDisplay:YES error:&error];
	}
	
	NSWindowController* windowController = [[document windowControllers]
		objectAtIndex: 0];
	
	NSEnumerator* tabEnumerator = [tabs objectEnumerator];
	NSURL* tab;
	
	BOOL firstTab = YES;
	
	while( tab = [tabEnumerator nextObject] ) {
		// If this is the first tab...
		if (firstTab == YES) {
			// Just load the URL in Safari
			[document goToURL: tab];
			firstTab = NO;
		} else {
			// otherwise, create a new tab and load the URL there.
			WebView* webView = [windowController createTab];
			[[webView mainFrame] loadRequest:
				[NSURLRequest requestWithURL: tab]];
		}
	}
	
	return;
}

-(void)openBrowserWithURLs:(NSArray*)tabs
{
	[self openBrowserWithURLs: tabs inDocument: nil];

	return;
}

- (IBAction)unclose:(id)sender
{
	[self openBrowserWithURLs: [self mostRecentlyClosedWindow]];
	[closedWindows removeLastObject];
}

-(BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	// If we are asked to validate the unclose menu item...
	if ([anItem action] == @selector(unclose:)) {
		// Answer yes if the plugin has tabs we can resurrect
		if ([self mostRecentlyClosedWindow] != nil)
			return YES;
		else
			return NO;
	}

	// Otherwise ask Safari to validate the item for us
	return NO;
}

- (NSArray*)mostRecentlyClosedWindow
{
	return [closedWindows lastObject];
}

- (void)rememberClosedWindow:(NSArray*)anArray
{
	[closedWindows addObject: anArray];
	
	return;
}

- (BOOL)isLoaded
{
	return YES;
}

- (BOOL)shouldReloadOnRelaunch
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObject:@"YES" forKey:@"jfShouldReloadOnRelaunch"];
	
    [defaults registerDefaults:appDefaults];

	return [[NSUserDefaults standardUserDefaults]
		boolForKey:@"jfShouldReloadOnRelaunch"];
}


@end
