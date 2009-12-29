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
#import "Safari.h"

@interface ForgetMeNotBrowserWindowController : NSObject

+ (void) ForgetMeNot_load;

- (NSArray*)_jf_openedTabs;

-(BOOL)_safari_windowShouldClose:(id)sender;
-(BOOL)_jf_windowShouldClose:(id)sender;

-(BOOL)_safari_closeTab:(id)tab;
-(BOOL)_jf_closeTab:(id)tab;

@end

