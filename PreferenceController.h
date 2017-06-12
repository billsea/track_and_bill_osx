//
//  PreferenceController.h
//  TrackAndBill_OSX
//
//  Created by Bill on 12/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferenceController : NSWindowController {
	
	
	//preference labels
	IBOutlet NSTextField *lblPrefsName;
	IBOutlet NSTextField *lblPrefsAddress;
	IBOutlet NSTextField *lblPrefsCity;
	IBOutlet NSTextField *lblPrefsState;
	IBOutlet NSTextField *lblPrefsPostal;
	IBOutlet NSTextField *lblPrefsPhone;
	IBOutlet NSTextField *lblPrefsEmail;
	IBOutlet NSTextField *lblPrefsContact;
	
	IBOutlet NSButton * prefsSaveButton;
	IBOutlet NSButton * prefsCloseButton;
	/////////////////////

	IBOutlet NSTabView *prefsTabView;
	IBOutlet NSTextField *txtMyName;
	IBOutlet NSTextField *txtMyAddress;
	IBOutlet NSTextField *txtMyCity;
	IBOutlet NSTextField *txtMyState;
	IBOutlet NSTextField *txtMyZip;
	IBOutlet NSTextField *txtMyPhone;
	IBOutlet NSTextField *txtMyEmail;
	IBOutlet NSTextField *txtMyContact;
	
	IBOutlet NSTextField *lblInvoiceImg;
	
	IBOutlet NSMatrix *dateFormat;
	IBOutlet NSButtonCell *mdySet;
	IBOutlet NSButtonCell *mdySet2;
	NSMutableArray *arrProfiles;
	
}
- (IBAction)selectInvoiceImage:(id)sender;
- (void)setDateFormat;
- (IBAction)saveChanges:(id)sender;
- (IBAction)cancelChanges:(id)sender;
- (void)saveDataToDisk;
- (NSString *) pathForDataFile;
- (void) loadDataFromDisk;
-(void) loadSettings;
-(void) writeSettings:(NSString*)plistKey :(NSString*)plistValue;
- (int)getDateFormatSetting;
@end
