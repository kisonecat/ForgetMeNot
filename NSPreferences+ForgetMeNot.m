//
//  NSPreferences+ForgetMeNot.m
//  ForgetMeNot
//
//  Created by Jim Fowler on 8/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSPreferences+ForgetMeNot.h"
#import "ForgetMeNotPreferences.h"

@implementation NSPreferences_ForgetMeNot

+ (void) load
{
	[NSPreferences_ForgetMeNot poseAsClass:[NSPreferences class]];
}

+ sharedPreferences
{
	static BOOL	added = NO;
	id preferences = [super sharedPreferences];
	
	if(preferences != nil && !added)
	{
		added = YES;
		[preferences addPreferenceNamed:@"ForgetMeNot" owner:[ForgetMeNotPreferences sharedInstance]];
	}
	
	return preferences;
}

/*
- (NSWindow*) window
{
	return preferencesPanel;
}
*/

@end
