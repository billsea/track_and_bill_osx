/* appController */

#import <Cocoa/Cocoa.h>
#import <Project.h>
@class PreferenceController;

@interface appController : NSObject 
{
	IBOutlet NSTabView *mainTabView;
	IBOutlet NSTableView *tableView;
	IBOutlet NSTableView *clientsView;
	IBOutlet NSTableView *sessionsView;
	IBOutlet NSTableView *allSessionsView;
	IBOutlet NSTableView *invoicesView;
	IBOutlet NSWindow *notesWindow;
	IBOutlet NSTextView *txtNotesEntry;
	
	IBOutlet NSWindow *invoiceWindow;
        IBOutlet NSTextField *txtInvoiceNumber;

        // preference labels
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
	
	IBOutlet NSTextField *txtMyName;
	IBOutlet NSTextField *txtMyAddress;
	IBOutlet NSTextField *txtMyCity;
	IBOutlet NSTextField *txtMyState;
	IBOutlet NSTextField *txtMyZip;
	
	IBOutlet NSTextField *txtMyPhone;
	IBOutlet NSTextField *txtClientName;
	IBOutlet NSTextField *txtClientAddress;
	IBOutlet NSTextField *txtClientCity;
	IBOutlet NSTextField *txtClientState;
	IBOutlet NSTextField *txtClientZip;
	IBOutlet NSTextField *txtApprovedBy;
	IBOutlet NSTextField *txtTerms;
	IBOutlet NSTextField *txtProjectName;
	IBOutlet NSTextField *txtStartDate;
	IBOutlet NSTextField *txtEndDate;
	IBOutlet NSTextField *txtInvoiceDate;
	IBOutlet NSTextView *txtServices;
	IBOutlet NSTextView *txtMaterials;
	IBOutlet NSTextField *txtHours;
	IBOutlet NSTextField *txtRate;
	IBOutlet NSTextField *txtSubTotal;
	IBOutlet NSTextField *txtMaterialsTotal;
	IBOutlet NSTextField *txtDeposit;
	IBOutlet NSTextField *txtTotalDue;
	IBOutlet NSTextField *txtCheckNumber;
	IBOutlet NSImageView *invoiceImageDisplay;
	IBOutlet NSMenuItem *fileMenuSave;
	
	PreferenceController *preferenceController;
	IBOutlet NSBox *invoiceBox;
	
	NSMutableArray *arrProjects;
	NSMutableArray *arrClients;
	NSMutableArray *arrSessions;
	NSMutableArray *storedSessions;
	NSMutableArray *selSessions;
	NSMutableArray *arrInvoices;
	
	//Registration types
	IBOutlet NSWindow * regCustomSheet;
	IBOutlet NSTextField * regNumberField;
	IBOutlet NSButton * regLater;
	IBOutlet NSTextField * remainingEvaluationTime;
	IBOutlet NSButton * butQuit;
}

- (NSString *)createRandomID;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (IBAction) openPrimoSite:(id)sender;
- (IBAction) appHelpLink:(id)sender;
- (IBAction) addProject:(id)sender;
- (NSString *)createProjectID;
- (IBAction)deleteProject:(id)sender;
- (IBAction)addClient:(id)sender;
- (IBAction)deleteClient:(id)sender;
- (IBAction)addSession:(id)sender;
- (IBAction)deleteSession:(id)sender;
- (IBAction)deleteStoredSession:(id)sender;
- (IBAction)viewSessions:(id)sender;
- (IBAction)exportProjectSessions:(id)sender;
- (IBAction)exportSelectedSessions:(id)sender;

- (void)viewSelectedSessions;
- (IBAction)clearSessions:(id)sender;
- (int)getSelTabIndex;
- (void)startClockTimer:(id)sender;
- (void)newSessionButtons:(id)tSession :(int)type;

- (IBAction)raiseNotesWindow:(id)sender;
- (IBAction)endNotesWindow:(id)sender;
- (void)sheetDidEnd:(NSWindow *)sheet
		 returnCode:(int)returnCode
		contectInfo:(void *)contextInfo;
- (IBAction)raiseInvoiceWindow:(id)sender;
- (IBAction)endInvoiceWindow:(id)sender;
- (IBAction)quickTimerStart:(id)sender;
- (void)computeTotalTime;
- (IBAction)addInvoice:(id)sender;
- (IBAction)deleteInvoice:(id)sender;
- (void)setDateFormat;
- (int)getDateFormatSetting;
- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void *)contextInfo;

// Registration
- (void)showRegistrationSheet:(BOOL)useCount;
- (IBAction)endRegistrationWindow:(id)sender;
- (IBAction) openRegistrationSite:(id)sender;
- (IBAction)serialNumberEntry:(id)sender;
- (IBAction)unloadApp:(id)sender;

- (NSString *)createInvoiceNumber;

//saving and loading
- (NSString *) pathForDataFile:(int)sFile;
- (void) saveDataToDisk:(int)sFile;
- (void) loadDataFromDisk:(int)sFile;
- (void) setProjects: (NSArray *)newProjects;
- (NSMutableArray *)addStoredSessions;
- (void)saveData:(NSNotification *)note;
- (void)willTerminate:(NSNotification *)notif;
- (IBAction)promptQTchange:(id)sender;
- (void) setInvoices: (NSArray *)newInvoices;
- (IBAction)print:(id)sender;

- (IBAction)showPreferenceController:(id)sender;

@end

