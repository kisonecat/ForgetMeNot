//
//  NSApplication.m
//  ForgetMeNot
//
//  Created by Jim Fowler on 9/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSApplication.h"


@implementation NSApplication (JFSwizzle)

- (NSUndoManager*)undoManager
{
	static NSUndoManager* myUndoManager = nil;
	
	if (myUndoManager == nil) {
		myUndoManager = [[NSUndoManager alloc] init];
		
		[myUndoManager retain];
	}
	
	return myUndoManager;
}

@end
