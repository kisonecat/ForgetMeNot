//
//  ForgetMeNotPreferences.m
//  ForgetMeNot
//
//  Created by Jim Fowler on 8/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "JFSafariPlugin.h"
#import "ForgetMeNotPreferences.h"


@implementation ForgetMeNotPreferences

+ (NSImage*) preloadImage:(NSString*)_name
{
	NSImage* image = nil;
	NSString* imagePath = [[NSBundle bundleWithIdentifier:@"com.fowler.forgetmenot"] pathForImageResource:_name];

	if (!imagePath)
	{
		NSLog(@"imagePath for %@ is nil", _name);
		return nil;
	}
	
	image = [[NSImage alloc] initByReferencingFile:imagePath];

	if (!image)
	{
		NSLog(@"image for %@ is nil", _name);
		return nil;
	}
	
	[image setName:_name];
	
	return image;
}

- (void) awakeFromNib
{
	NSDictionary* infoDictionary = [[NSBundle bundleWithIdentifier:@"com.fowler.forgetmenot"] infoDictionary];
	
	[authorTextField setStringValue:
		[NSString stringWithFormat:[authorTextField stringValue],
			[infoDictionary objectForKey:@"CFBundleShortVersionString"],
			[infoDictionary objectForKey:@"CFBundleVersion"]]];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jfShouldReloadOnRelaunch"]) {
		[checkboxShouldReloadOnRelaunch setState: NSOnState];
	} else {
		[checkboxShouldReloadOnRelaunch setState: NSOffState];
	}
}

/**
* Image to display in the preferences toolbar
 */
- (NSImage *) imageForPreferenceNamed:(NSString *)_name
{
	NSImage* image = [NSImage imageNamed:@"Forget Me Not"];
	
	if (image == nil) {
		image = [ForgetMeNotPreferences preloadImage:@"Forget Me Not"];
	}
	
	return image;
}

	/**
	* Override to return the name of the relevant nib
	 */
- (NSString *) preferencesNibName
{
	return @"ForgetMeNotPreferences";
}

- (void) didChange
{
	[super didChange];
}

- (NSView*) viewForPreferenceNamed:(NSString *)aName
{
	if ([[JFSafariPlugin sharedInstance] isLoaded] == NO)
		return nil;
	
	NSView* view = [super viewForPreferenceNamed:aName];
	
	return view;
}

	/**
	* Called when switching preference panels.
	 */
- (void) willBeDisplayed
{
	if ([[JFSafariPlugin sharedInstance] isLoaded] == NO)
		return;

	// [self initializeFromDefaults];
}

	/**
	* Called when window closes or "save" button is clicked.
	 */
- (void) saveChanges
{
	if ([[JFSafariPlugin sharedInstance] isLoaded] == NO)
		return;

	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	if ([checkboxShouldReloadOnRelaunch state]) {
		[defaults setObject:@"YES" forKey:@"jfShouldReloadOnRelaunch"];
	} else {
		[defaults setObject:@"NO" forKey:@"jfShouldReloadOnRelaunch"];
	}
	
	[defaults synchronize];

	return;
}

	/**
	* Not sure how useful this is, so far always seems to return YES.
	 */
- (BOOL) hasChangesPending
{
	return [super hasChangesPending];
}

	/**
	* Called when we relinquish ownership of the preferences panel.
	 */
- (void)moduleWillBeRemoved
{
	[super moduleWillBeRemoved];
}

	/**
	* Called after willBeDisplayed, once we "own" the preferences panel.
	 */
- (void)moduleWasInstalled
{
	[super moduleWasInstalled];

	if ([[JFSafariPlugin sharedInstance] isLoaded] == NO)
		NSLog( @"ForgetMeNot: Did Not Load.\n" );
}

- (IBAction)donate:(id)sender
{
	[[NSWorkspace sharedWorkspace]
		openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=jim%40uchicago%2eedu&item_name=Forget%20Me%20Not&no_shipping=2&no_note=1&tax=0&currency_code=USD&bn=PP%2dDonationsBF&charset=UTF%2d8"]];
}

- (IBAction)upgrade:(id)sender
{
	[[NSWorkspace sharedWorkspace]
		openURL:[NSURL URLWithString:@"http://math.uchicago.edu/~fowler/Software.html"]];
}

- (IBAction)reportBug:(id)sender
{
	[[NSWorkspace sharedWorkspace]
		openURL:[NSURL URLWithString:@"mailto:jim@uchicago.edu?subject=Forget%20Me%20Not"]];
}

@end
