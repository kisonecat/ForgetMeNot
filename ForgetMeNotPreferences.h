//
//  ForgetMeNotPreferences.h
//  ForgetMeNot
//
//  Created by Jim Fowler on 8/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSPreferenceModule.h"

@interface ForgetMeNotPreferences : NSPreferencesModule {
	IBOutlet NSTextField* authorTextField;
	
	IBOutlet NSButton* checkboxShouldReloadOnRelaunch;
}

- (IBAction)donate:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)reportBug:(id)sender;

@end
