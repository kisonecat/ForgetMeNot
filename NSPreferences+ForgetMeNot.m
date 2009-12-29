//
//  NSPreferences+ForgetMeNot.m
//  ForgetMeNot
//
//  Created by Jim Fowler on 8/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#ifdef __OBJC2__
#include <objc/objc.h>
#include <objc/runtime.h>
#endif

#import "NSPreferences+ForgetMeNot.h"
#import "ForgetMeNotPreferences.h"

#ifdef __OBJC2__
@implementation NSPreferences (NSPreferences_ForgetMeNot)
#else
@implementation NSPreferences_ForgetMeNot
#endif

+ (void) load
{
#ifdef __OBJC2__
	  Class c = [self class];
	  Method old = class_getClassMethod(c, @selector(sharedPreferences));
	  Method new = class_getClassMethod(c, @selector(_ForgetMeNot_sharedPreferences));
	  method_exchangeImplementations(old, new);
#else
	[NSPreferences_ForgetMeNot poseAsClass:[NSPreferences class]];
#endif
}

#ifdef __OBJC2__
+ (id) _ForgetMeNot_sharedPreferences
#else
+ (id) sharedPreferences
#endif
{
	static BOOL	added = NO;
	
#ifdef __OBJC2__
	id preferences = [self _ForgetMeNot_sharedPreferences];
#else
	id preferences = [super sharedPreferences];
#endif
	
	if(preferences != nil && !added)
	{
		added = YES;
		[preferences addPreferenceNamed:@"ForgetMeNot" owner:[ForgetMeNotPreferences sharedInstance]];
	}
	
	return preferences;
}

@end
