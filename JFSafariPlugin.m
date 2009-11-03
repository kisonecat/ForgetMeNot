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

/* Code for doing method swizzling. */

typedef struct objc_method *Method;

struct objc_method {
  SEL method_name;
  char *method_types;
  IMP method_imp;
};

BOOL JFRenameSelector(Class _class, SEL _oldSelector, SEL _newSelector)
{
        Method method = nil;

        // Look for the methods
        method = (Method)class_getInstanceMethod(_class, _oldSelector);
        if (method == nil)
                return NO;

		// Point the method to a new function
        method->method_name = _newSelector;
        return YES;
}

@implementation JFSafariPlugin

/*
 * A special method called by SIMBL once the application has started and all classes are initialized.
 */
+ (void) load
{
	NSLog(@"ForgetMeNot installed.");
		
	// Exchange Safari's applicationDidFinishLaunching: with ours.
    JFRenameSelector([AppController class], @selector(applicationDidFinishLaunching:), @selector (_safari_applicationDidFinishLaunching:));
	JFRenameSelector([AppController class], @selector(_jf_applicationDidFinishLaunching:), @selector(applicationDidFinishLaunching:));

	// Exchange Safari's applicationWillTerminate: with ours.
	JFRenameSelector([AppController class], @selector(applicationWillTerminate:), @selector (_safari_applicationWillTerminate:));
	JFRenameSelector([AppController class], @selector(_jf_applicationWillTerminate:), @selector(applicationWillTerminate:));

	// Exchange Safari's validateUserInterfaceItem: with ours.
	JFRenameSelector([AppController class], @selector(validateUserInterfaceItem:), @selector (_safari_validateUserInterfaceItem:));
	JFRenameSelector([AppController class], @selector(_jf_validateUserInterfaceItem:), @selector(validateUserInterfaceItem:));

	// Exchange Safari's application:openFile: with ours.
	JFRenameSelector([AppController class], @selector(application:openFile:), @selector (_safari_application:openFile:));
	JFRenameSelector([AppController class], @selector(_jf_application:openFile:), @selector(application:openFile:));	

	// Exchange Safari's handleURLEvent:withReplyEvent: with ours.
	JFRenameSelector([AppController class], @selector(handleURLEvent:withReplyEvent:), @selector (_safari_handleURLEvent:withReplyEvent:));
	JFRenameSelector([AppController class], @selector(_jf_handleURLEvent:withReplyEvent:), @selector(handleURLEvent:withReplyEvent:));	
	
	// Exchange Safari's windowShouldClose: with ours.
    JFRenameSelector([BrowserWindowController class], @selector(windowShouldClose:), @selector (_safari_windowShouldClose:));
	JFRenameSelector([BrowserWindowController class], @selector(_jf_windowShouldClose:), @selector(windowShouldClose:));	

	// Exchange Safari's windowWillClose: with ours.
    JFRenameSelector([BrowserWindowController class], @selector(windowWillClose:), @selector (_safari_windowWillClose:));
	JFRenameSelector([BrowserWindowController class], @selector(_jf_windowWillClose:), @selector(windowWillClose:));		
	
	// Exchange Safari's windowShouldClose: with ours.
    JFRenameSelector([BrowserWindowController class], @selector(closeTab:), @selector (_safari_closeTab:));
	JFRenameSelector([BrowserWindowController class], @selector(_jf_closeTab:), @selector(closeTab:));	
	
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
