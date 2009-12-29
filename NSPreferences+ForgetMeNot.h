//
//  NSPreferences+ForgetMeNot.h
//  ForgetMeNot
//
//  Created by Jim Fowler on 8/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSPreferenceModule.h"

#ifdef __OBJC2__
@interface NSPreferences (NSPreferences_ForgetMeNot)
#else
@interface NSPreferences_ForgetMeNot : NSPreferences {
}
#endif

+ (void) load;
- (NSWindow*) window;

@end
