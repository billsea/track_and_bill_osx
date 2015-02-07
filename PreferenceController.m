//
//  PreferenceController.m
//  TrackAndBill_OSX
//
//  Created by Bill on 12/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"
#import "Profile.h"

@implementation PreferenceController
- (id)init
{

	self=[super initWithWindowNibName:@"Preferences"];
	arrProfiles = [[NSMutableArray alloc] init];
	
	
	
	

	return self;
	
}
- (void)windowDidLoad
{
	[self loadDataFromDisk];
	
	
	//set localization strings
	[lblPrefsName setStringValue:NSLocalizedString(@"PrefsName", @"PrefsName")];
	[lblPrefsAddress setStringValue:NSLocalizedString(@"PrefsAddress", @"PrefsAddress")];
	[lblPrefsCity setStringValue:NSLocalizedString(@"PrefsCity", @"PrefsCity")];
	[lblPrefsState setStringValue:NSLocalizedString(@"PrefsState", @"PrefsState")];
	[lblPrefsPostal setStringValue:NSLocalizedString(@"PrefsPostal", @"PrefsPostal")];
	[lblPrefsPhone setStringValue:NSLocalizedString(@"PrefsPhone", @"PrefsPhone")];
	[lblPrefsEmail setStringValue:NSLocalizedString(@"PrefsEmail", @"PrefsEmail")];
	[lblPrefsContact setStringValue:NSLocalizedString(@"PrefsContact", @"PrefsContact")];
	[prefsSaveButton setTitle:NSLocalizedString(@"prefsSaveButton", @"prefsSaveButton")];
	[prefsCloseButton setTitle:NSLocalizedString(@"prefsCloseButton", @"prefsCloseButton")];
	
	//[prefsTabView
	NSTabViewItem *profileTab = [prefsTabView tabViewItemAtIndex:0];
	[profileTab setLabel:NSLocalizedString(@"prefsTab1", @"prefsTab1")];
	NSTabViewItem *settingsTab = [prefsTabView tabViewItemAtIndex:1];
	[settingsTab setLabel:NSLocalizedString(@"prefsTab2", @"prefsTab2")];
	
	//load settings
	[self loadSettings];
	
	NSLog(@"Prefs nib loaded");
	
}

- (IBAction)saveChanges:(id)sender
{
	
	[self setDateFormat];
	
	int err;
	//save plist setting
	[self writeSettings:@"invoiceImage" :[lblInvoiceImg stringValue]];
	
	
	Profile *nProfile = [[Profile alloc] init];
	//Only one profile allowed for now
	if ([arrProfiles count] < 1) {
			[arrProfiles addObject:nProfile];
		}
	[[arrProfiles objectAtIndex:0] setProfileName:[txtMyName stringValue]];
	[[arrProfiles objectAtIndex:0] setProfileAddress:[txtMyAddress stringValue]];
	[[arrProfiles objectAtIndex:0] setProfileCity:[txtMyCity stringValue]];
	[[arrProfiles objectAtIndex:0] setProfileState:[txtMyState stringValue]];
	[[arrProfiles objectAtIndex:0] setProfileZip:[txtMyZip stringValue]];
	[[arrProfiles objectAtIndex:0] setProfilePhone:[txtMyPhone stringValue]];
	[[arrProfiles objectAtIndex:0] setProfileEmail:[txtMyEmail stringValue]];
	[[arrProfiles objectAtIndex:0] setProfileContact:[txtMyContact stringValue]];
	
	[self saveDataToDisk];
	//NSLog(@"clients count = %@",tString);
	
	[nProfile release];	
	
	
}

- (IBAction)cancelChanges:(id)sender
{
	[self close];

}

// Saving and loading data
- (void) saveDataToDisk
{
	int err;
	NSMutableDictionary * rootObject;
	rootObject = [NSMutableDictionary dictionary];
	
			NSString *path = [self pathForDataFile];
			[rootObject setValue:arrProfiles forKey:@"profile"];
			[NSKeyedArchiver archiveRootObject: rootObject toFile: path];
			
			
			err = NSRunAlertPanel(NSLocalizedString(@"selSettings", @"selSettings"), NSLocalizedString(@"selSetSave", @"selSetSave"), @"sOK", nil, nil);
			
			
}


- (NSString *) pathForDataFile
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/TrackAndBill_OSX"; //destination folder
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO)
	{
		[fileManager createDirectoryAtPath: folder attributes: nil];
	}

			NSString *fileName = @"profiles.tbd"; //new file name
			return [folder stringByAppendingPathComponent: fileName]; 
			
}

- (void) setProfiles: (NSArray *)newProfiles
{
    if (arrProfiles != newProfiles)
    {

        [arrProfiles autorelease];
        arrProfiles = [[NSMutableArray alloc] initWithArray: newProfiles];
			
		if ([arrProfiles count] > 0 ){

			if ([[arrProfiles objectAtIndex:0] profileName] != nil){
				[txtMyName setStringValue:[[arrProfiles objectAtIndex:0] profileName]];
			}
			if ([[arrProfiles objectAtIndex:0] profileAddress] != nil){
				[txtMyAddress setStringValue:[[arrProfiles objectAtIndex:0] profileAddress]];
			}
			if ([[arrProfiles objectAtIndex:0] profileCity] != nil){
				[txtMyCity setStringValue:[[arrProfiles objectAtIndex:0] profileCity]];
			}
			if ([[arrProfiles objectAtIndex:0] profileState] != nil){
				[txtMyState setStringValue:[[arrProfiles objectAtIndex:0] profileState]];
			}
			if ([[arrProfiles objectAtIndex:0] profileZip] != nil){
				[txtMyZip setStringValue:[[arrProfiles objectAtIndex:0] profileZip]];
			}
			if ([[arrProfiles objectAtIndex:0] profilePhone] != nil){
					[txtMyPhone setStringValue:[[arrProfiles objectAtIndex:0] profilePhone]];
			}
				if ([[arrProfiles objectAtIndex:0] profileEmail] != nil){
					[txtMyEmail setStringValue:[[arrProfiles objectAtIndex:0] profileEmail]];
				}
			if ([[arrProfiles objectAtIndex:0] profileContact] != nil){
				[txtMyContact setStringValue:[[arrProfiles objectAtIndex:0] profileContact]];
			}
		}
    }
}

- (void)setDateFormat
{


	if ([mdySet state]==NSOnState){
		[self writeSettings:@"dateFormat": @"0"];
	}else{
		[self writeSettings:@"dateFormat": @"1"];
	}

	
	NSLog(@"date format changed: %d.\n", [mdySet state]); 
	
}

- (IBAction)selectInvoiceImage:(id)sender
{
	
	int result; 
	NSOpenPanel *oPanel = [NSOpenPanel openPanel]; 
	NSString *theFileName; 
	// All file types NSSound understands 
	[oPanel setAllowsMultipleSelection:NO]; 
	result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil 
									types:nil]; 
	if (result == NSOKButton) { 
		 
		theFileName = [oPanel filename]; 
		[lblInvoiceImg setStringValue:theFileName];
		
		NSLog(@"Open Panel Returned: %@.\n", theFileName); 
	
	}
	

}

-(void) writeSettings:(NSString*)plistKey:(NSString*)plistValue
{
	//store this in settings plist file
	NSString *settingsPath = [[NSBundle bundleWithIdentifier: @"com.primomedia.TrackAndBill"] pathForResource:@"tbSettings" ofType:@"plist"];
	NSMutableDictionary * settingsDict;
	settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	
	[settingsDict setObject:plistValue forKey:plistKey];
	[settingsDict writeToFile:settingsPath atomically:nil]; //write back to plist file
	
	NSLog(@"settings saved key: %@.\n", plistKey); 
	NSLog(@"settings saved value: %@.\n", plistValue); 
}

-(void) loadSettings
{
	//load plist settings
	NSString *settingsPath = [[NSBundle bundleWithIdentifier: @"com.primomedia.TrackAndBill"] pathForResource:@"tbSettings" ofType:@"plist"];
	NSMutableDictionary * settingsDict;
	settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	
	if ([self getDateFormatSetting]==0){
		[mdySet setState:NSOnState];
		[mdySet2 setState:NSOffState];
	}else{
		[mdySet setState:NSOffState];
		[mdySet2 setState:NSOnState];
	}
	
	
	//[dateFormat selectCellWithTag:[[settingsDict objectForKey:@"dateFormat"] intValue]];
	[lblInvoiceImg setStringValue:[settingsDict objectForKey:@"invoiceImage"]];
}

- (int)getDateFormatSetting
{
	NSString *settingsPath = [[NSBundle bundleWithIdentifier: @"com.primomedia.TrackAndBill"] pathForResource:@"tbSettings" ofType:@"plist"];
	NSMutableDictionary * settingsDict;
	settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	
	NSLog(@"date format is = %d",[[settingsDict objectForKey:@"dateFormat"] intValue] );
	
	return [[settingsDict objectForKey:@"dateFormat"] intValue] ;
	
}

////////////////////////////////////////////////////////////////////////////////////////////////
//// Load data from file
//////////////////////////

- (void) loadDataFromDisk
{

			NSString     * path        = [self pathForDataFile];
			NSDictionary * rootObject;
			rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
			[self setProfiles: [rootObject valueForKey:@"profile"]];
}
@end
