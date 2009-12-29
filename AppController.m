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

#include <objc/objc.h>
#include <objc/runtime.h>

#import "AppController.h"
#import <WebKit/WebKit.h>
#import "BrowserWindowController.h"
#import "JFSafariPlugin.h"

@implementation ForgetMeNotAppController

+ (void) ForgetMeNot_load
{
	Method old, new;
	Class self_class = [self class];
    Class safari_class = [objc_getClass("AppController") class];
    //NSLog(@"%@\n", objc_getClass("AppController"));

	//NSLog(@"[NSApplication delegate] = %@\n", [[NSApplication sharedApplication] delegate] );

	if ([[JFSafariPlugin sharedInstance] shouldReloadOnRelaunch]) {
		NSLog( @"sendAction reopenLastSession:\n" );
		[[NSApplication sharedApplication] sendAction:@selector(reopenLastSession:) to:nil from:self];
	}

	class_addMethod(safari_class, @selector(_forgetMeNot_validateUserInterfaceItem:),
                    class_getMethodImplementation(self_class, @selector(validateUserInterfaceItem:)),
                    "l@:@");
	
	old = class_getInstanceMethod(safari_class, @selector(validateUserInterfaceItem:));
	new = class_getInstanceMethod(safari_class, @selector(_forgetMeNot_validateUserInterfaceItem:));
	method_exchangeImplementations(old, new);
}

/* There will be some warnings when we compile this; we are missing the
   implementations of _safari_... */

////////////////////////////////////////////////////////////
// Swizzled validation - validate our unclose menu item
-(BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
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
	return [self _forgetMeNot_validateUserInterfaceItem: anItem];
}

@end
