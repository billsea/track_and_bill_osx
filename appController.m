#import "appController.h"
#import "Project.h"
#import "Client.h"
#import "Session.h"
#import "Invoice.h"
#import "Profile.h"
#import "PreferenceController.h"
//#import "FileSystemItem.h"

@implementation appController


- (id)init
{

	
	self = [super init];
    if (self) {
		
	
			
		
		//Register notification center observer
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(saveData:)
				   name:@"BNRDataAdded"
				 object:nil];
		
		
		
		//observer for terminate
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(willTerminate:)
													 name:NSApplicationWillTerminateNotification
												   object:nil];
		
		arrProjects = [[NSMutableArray alloc] init];
		arrClients = [[NSMutableArray alloc] init];
		arrSessions = [[NSMutableArray alloc] init];
		storedSessions = [[NSMutableArray alloc] init];
		arrInvoices = [[NSMutableArray alloc] init];

		//Load data from files
		[self loadDataFromDisk:0];
		[self loadDataFromDisk:1];
		[self loadDataFromDisk:2]; //load stored sessions
		[self loadDataFromDisk:3];

		//compute totaltime
		[self computeTotalTime];

			
		
    }
	return self;
}

-(void)awakeFromNib
{

	//NSLog(@"nib loaded....");
	[self evaluationCheck];

}

- (NSMutableArray *) arrProjects
{
    return arrProjects;
}

- (NSMutableArray *) arrClients
{
    return arrClients;
}
- (NSMutableArray *) arrSessions
{
    return arrSessions;
}

- (NSMutableArray *) storedSessions
{
    return storedSessions;
}
- (NSMutableArray *) arrInvoices
{
    return arrInvoices;
}

/////////////////////////////////////////////////////////////////////////////////
////////////////////// Evaluation and Registration Functions ////////////////////
/////////////////////////////////////////////////////////////////////////////////
- (void)evaluationCheck
{
	
	//check evaluation period and registration (rgLicTBBTS.plist)
	int evalLimit = 14; // evaluation days - limit
	NSString * regInitDate;
	long expiredDays;
	BOOL evalExpired = FALSE;
	NSString *regPath = [[NSBundle bundleWithIdentifier: @"com.primomedia.TrackAndBill"] pathForResource:@"rgLicTBBTS" ofType:@"plist"];
	NSMutableDictionary * regDict;
	regDict = [NSMutableDictionary dictionaryWithContentsOfFile:regPath];
	
	//show remaining evaluation time, allow for serial number entry, or kill.
	NSString * serialNum = [[NSString alloc] initWithString:@"TC5597332243"]; //this is also set in (IBAction)serialNumberEntry:(id)sender
	
	if ([ [regDict objectForKey:@"serial"] isEqual: serialNum])
	{
		//NSLog(@"serial number is ok");
		
	}else{
		
		NSCalendarDate * today;
		today = [NSCalendarDate date];
		NSString * noVal = [[NSString alloc] initWithString:@"???"];
		
		//set day of year value for regInit in plist of first use
		if ([[regDict objectForKey:@"regInit"] isEqual:noVal]){
			
			[regDict setObject:today forKey:@"regInit"];
			[regDict writeToFile:regPath atomically:nil];
			
			regInitDate= [regDict objectForKey:@"regInit"]  ;
			
            NSDate * dInitDate = [NSDate dateWithString:regInitDate];
			//NSDate * dInitDate = regInitDate;// format: 2007-01-14 17:15:30 -0800
				
				long tSecs1 = [today timeIntervalSinceDate:dInitDate];
				expiredDays = tSecs1/86400;
				
		}else{
			
			regInitDate = [regDict objectForKey:@"regInit"];
			
            NSLog(@"regInitDate:%@", regInitDate);
			//this seems odd but it works...
            //NSDate * dInitDate = [NSDate dateWithString:regInitDate];
			NSDate * dInitDate = regInitDate;// format: 2007-01-14 17:15:30 -0800
				
				long tSecs = [today timeIntervalSinceDate:dInitDate];
				expiredDays = tSecs/86400;
				//NSLog(@"Interval since init time(days) = %d", expiredDays); 	 
		}
		
		if (expiredDays > evalLimit){
			evalExpired = TRUE;
			//NSLog(@"Expired = true"); 
		}
		
		int remainingEvalDays = evalLimit - expiredDays;
		[remainingEvaluationTime setIntValue:remainingEvalDays];
		
		//Debug
		//NSLog(@"Init date = %@", regInitDate); 
		//NSLog(@"serial number value = %@", [regDict objectForKey:@"serial"]); 
		// NSLog(@"today = %d", [today dayOfYear]); 
		
		// Show registration sheet
		[self showRegistrationSheet:evalExpired];
		
	}
	
}

- (void)showRegistrationSheet:(BOOL)expired

	// User has asked to see the custom display. Display it.
{
  
	
	//if evaluation expired, disable "Register later" button
	
	if (expired == TRUE)
	{
		[regLater setHidden:TRUE];
		
		[butQuit setHidden:FALSE];
		
	}
	
		
		[NSApp beginSheet:regCustomSheet
		   modalForWindow:[mainTabView window] 
			modalDelegate:nil
		   didEndSelector:nil
			  contextInfo:nil];
	
	[NSApp runModalForWindow: regCustomSheet];
	
    // Dialog is up here.
    [NSApp endSheet: regCustomSheet];
    [regCustomSheet orderOut: self];

}

- (IBAction)serialNumberEntry:(id)sender
{
	NSString * serialNum = [[NSString alloc] initWithString:@"TC5597332243"];//valid registration number
	if ([ [regNumberField stringValue] isEqual: serialNum])
	{
		//enter serial number into registration plist
		NSString *regPath = [[NSBundle bundleWithIdentifier: @"com.primomedia.TrackAndBill"] pathForResource:@"rgLicTBBTS" ofType:@"plist"];
		NSMutableDictionary * regDict;
		regDict = [NSMutableDictionary dictionaryWithContentsOfFile:regPath];
		[regDict setObject:[regNumberField stringValue] forKey:@"serial"];
		[regDict writeToFile:regPath atomically:nil]; //write back to rgLicTBBTS.plist file
		
		//int serNum = NSRunAlertPanel(NSLocalizedString(@"regCompleted", @"regCompleted"), NSLocalizedString(@"regThanks", @"regThanks"),nil, nil,nil,nil);
		
		[NSApp endSheet:regCustomSheet returnCode:1];
		[NSApp endSheet:regCustomSheet returnCode:1];
	}else{
		//Show error on registration
		//int serNum = NSRunAlertPanel(NSLocalizedString(@"regError", @"regError"), NSLocalizedString(@"regErrorMessage", @"regErrorMessage"),nil, nil,nil,nil);
		
	}
}

- (IBAction)endRegistrationWindow:(id)sender
{

	//return to normal event handling
	[NSApp endSheet:regCustomSheet returnCode:1];
	[NSApp endSheet:regCustomSheet returnCode:1];
}

- (IBAction)unloadApp:(id)sender;
{
	
	//int serNum = NSRunAlertPanel(NSLocalizedString(@"evalThanks", @"evalThanks"), NSLocalizedString(@"evalRegNow", @"evalRegNow"),nil, nil,nil,nil);
	
// Terminate app
	[NSApp endSheet:regCustomSheet returnCode:1];
	[NSApp terminate:sender];
	
}

- (IBAction) openRegistrationSite:(id)sender
{
	
	NSString *stringURL = @"http://primo-media.com/?page_Request=Downloads";
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:stringURL]];
}

/////////////////////////////////////////////////////////////////////////////////
//////// End   ----- Evaluation and Registration Functions -----End  ////////////
/////////////////////////////////////////////////////////////////////////////////



- (IBAction)addInvoice:(id)sender
{
	Project *selProject = [[Project alloc] init];
	Invoice *nInvoice = [[Invoice alloc] init];
	int err;
	int selRow = [tableView selectedRow]; //projects table selected row
	
	if (selRow >=0) {
		
		selProject = [arrProjects objectAtIndex:selRow];
		[nInvoice setInvoiceNumber:[self createInvoiceNumber]];
		[nInvoice setProjectName:[selProject projectName]];
		[nInvoice setProjectID:[selProject projectID]];
		[nInvoice setClientID:[selProject clientID]];
		[nInvoice setStartDate:[selProject startDate]];
		[nInvoice setEndDate:[selProject endDate]];
		[nInvoice setClientName:[selProject clientName]];
		[nInvoice setTotalTime:[selProject totalTime]];
		[nInvoice setApprovalName:@"-"];
		[nInvoice setInvoiceRate:0.00];
		
		//invoice notes from session notes
		NSString *allSessionNotes = [[NSString alloc] init];
		Session *iSession;
		int i;
		NSString *x = [[NSString alloc] init];
		NSString *y = [[NSString alloc] init];
		NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%y" allowNaturalLanguage:NO];
		NSString *MDY1;
		
		y = [nInvoice projectID];
		for (i=0;i<[storedSessions count]; i++){
			
			iSession = [storedSessions objectAtIndex:i];
			x = [iSession projectIDref];
			if ([x isEqual: y]){
				
				@try{
				
				//add session notes to list 
				allSessionNotes = [allSessionNotes stringByAppendingString:@"\n"];
				MDY1=[dateFormatter1 stringFromDate:[iSession sessionDate]];
				allSessionNotes = [allSessionNotes stringByAppendingString:MDY1];
				allSessionNotes = [allSessionNotes stringByAppendingString:@" - "];
				allSessionNotes = [allSessionNotes stringByAppendingString:[iSession txtNotes]];
				
				}@catch (NSException *exception) {
					NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
					allSessionNotes = [allSessionNotes stringByAppendingString:[iSession sessionDate]];
					allSessionNotes = [allSessionNotes stringByAppendingString:@" - "];
					allSessionNotes = [allSessionNotes stringByAppendingString:[iSession txtNotes]];
				}
				
			}
			
		}
		
		[nInvoice setInvoiceNotes:allSessionNotes];
		
		//////////////////////////
		
		[arrInvoices addObject:nInvoice];
		
		[invoicesView reloadData];
		
		//change tab
		NSTabViewItem *selItem = [mainTabView tabViewItemAtIndex:4];
		[mainTabView selectTabViewItem: selItem];		
		
	} else {
		err = NSRunAlertPanel(NSLocalizedString(@"selProject", @"selProject"), NSLocalizedString(@"selProjInvoice", @"selProjInvoice"), @"sOK", nil, nil);
		[selProject release];
		[nInvoice release];
	}
}
//create invoice number based on last invoice number
- (NSString *)createInvoiceNumber
{
	int invNumber;
	int tempNumber;
	int i;
	NSString *lastNumber;
	NSString *newNumber;
	
	if ([arrInvoices count] == 0) {
		return @"1";
	}else{
		
	Invoice *tInvoice = [[Invoice alloc] init];
	tempNumber = 0;
	
	for (i=0;i<[arrInvoices count];i++){
			
			tInvoice = [arrInvoices objectAtIndex:i];
			lastNumber = [tInvoice invoiceNumber];
			if ([lastNumber intValue] > tempNumber){
				tempNumber = [lastNumber intValue];
			}
		}
			//set new invoice number to the highest invoice number found, plus one.
			invNumber = tempNumber;
			invNumber++; 
			newNumber = [NSString stringWithFormat:@"%d", invNumber];
			return newNumber;	
	}
}

- (IBAction)deleteInvoice:(id)sender
{
	int err;
	int validateAction;
	
	//Localized example 
	validateAction = NSRunAlertPanel(NSLocalizedString(@"delInvoice", @"delInvoice"), NSLocalizedString(@"delInvoiceConfirm", @"delInvoiceConfirm"), NSLocalizedString(@"sYes", @"sYes"), NSLocalizedString(@"sNo", @"sNo"), NSLocalizedString(@"Cancel", @"Cancel"));
	
	if (validateAction == 1){
		
		if ([self getSelTabIndex] == 4){
			
				//determine selected row
				NSIndexSet *rows =[invoicesView selectedRowIndexes];
		
				//check if any rows are selected
				if ([rows count] > 0) {
					unsigned int row = [rows lastIndex];
			
					//remove selected rows
					//while (row != NSNotFound){
						[arrInvoices removeObjectAtIndex:row];
						row =[rows indexLessThanIndex:row];
					//}
					[invoicesView reloadData];
				}else{
					NSBeep();
					err = NSRunAlertPanel(NSLocalizedString(@"selProject", @"selProject"), NSLocalizedString(@"selProjInvoice", @"selProjInvoice"), @"sOK", nil, nil);
				}
		}
	}
}

- (void)viewSelectedSessions
{
	selSessions=[[NSMutableArray alloc] init];
	Project *selProject = [[Project alloc] init];
	Session *targetSession=[[Session alloc] init];
	NSString *selProjID;
	NSString *targetProjID;
	int i;
	int selRow = [tableView selectedRow]; //projects table selected row
	
	
	if (selRow >=0) {
		
		selProject = [arrProjects objectAtIndex:selRow];
		selProjID= [selProject projectID];
		
		
		for(i=0;i<[storedSessions count];i++)
		{
			targetSession = [storedSessions objectAtIndex:i];
			targetProjID=[targetSession projectIDref];
			if ([selProjID isEqual :targetProjID])
			{
				break;
				/*
				//show only selected projects sessions-buggy
				[selSessions addObject:targetSession];
				//add buttons to list view for notes
				[self newSessionButtons:selSessions :0];
				 */
			}
		}
		
		[selSessions addObjectsFromArray:storedSessions];
		[self newSessionButtons:selSessions :0];
		//hightlight row(i) and move down
		[allSessionsView scrollRowToVisible:i];
		NSIndexSet *is =[NSIndexSet alloc];
		[is initWithIndex:i];
		[allSessionsView selectRowIndexes:is  byExtendingSelection:TRUE];
		
		
		
	} else {
		[selSessions addObjectsFromArray:storedSessions];//add all if nothing selected
		//add buttons to list view for notes
		[self newSessionButtons:selSessions :0];
	}


}


//View all sessions related to selected project
- (IBAction)viewSessions:(id)sender
{
	[self viewSelectedSessions];
	//change tab
	NSTabViewItem *selItem = [mainTabView tabViewItemAtIndex:3];
	[mainTabView selectTabViewItem: selItem];	
	
}

//create project ID
-(NSString *)createProjectID
{
	NSString *projIndex;
	NSString *newID = [self createRandomID];
	Session *tSession = [[Session alloc] init];
	int i;
	
	//check stored sessions and see if project id ref is used already, if so, generate a different project id;
	for (i=0;i<[storedSessions count];i++){
		
		tSession = [storedSessions objectAtIndex:i];
		projIndex = [tSession  projectIDref];
		
		if ([newID isEqual: projIndex]){
			newID = [self createRandomID];
			i=0;
		}

	}
	
	return newID;
}

//random number id
- (NSString *)createRandomID
{
	int fNum = random() % 100 + 1;
	int sNum = random() % 100 + 1;
	int tNum = random() % 100 + 1;
	int prod = (fNum * sNum) * tNum;
	
	NSCalendarDate *dSecs=[NSCalendarDate date];
	int secs = [dSecs minuteOfHour] + [dSecs secondOfMinute];
	
	NSString *temp = [NSString stringWithFormat:@"%d%d", prod, secs];
	return temp;
}

// Add each session elapsed time to project total time
- (void)computeTotalTime
{
	Session *ttSession;
	Project *ttProject;
	NSString *pProjectID;
	NSString *tempID;
	NSString *timeDisplay;
	int tSecs;
	int totalSeconds;
	int remainderSecs;
	int seconds;
	int minutes;
	int hours;
	int i;
	int z;
	
	//loop through projects and grab project ID
	for (i=0; i < [arrProjects count]; i++){
		
		ttProject = [arrProjects objectAtIndex:i];
		pProjectID =  [ttProject projectID];
		
		totalSeconds=0;
		for (z=0; z< [storedSessions count]; z++){
			//get sessions for each project and add-up times
			ttSession = [storedSessions objectAtIndex:z];
			tempID = [ttSession projectIDref];
			if ([tempID isEqual: pProjectID] ){
				
				tSecs = [[ttSession endTime] timeIntervalSinceDate:[ttSession startTime]];
				totalSeconds = totalSeconds + tSecs;
			}
		}
	//calculate HH:MM:SS
		hours = totalSeconds / 3600;
		remainderSecs = totalSeconds % 3600;
		minutes= remainderSecs / 60;
		remainderSecs = remainderSecs % 60;
		seconds = remainderSecs;
		
		timeDisplay = [NSString stringWithFormat:@"%d:%d:%d",hours,minutes,seconds];
		[ttProject setTotalTime:timeDisplay];
		
		totalSeconds = 0;
		}
}

//Set session start or end time 
- (void)startClockTimer:(id)sender
{
	NSButtonCell *selCell=[sender selectedCell];
	NSTableColumn *desiredColumn;
	Session *uSession;
	int selRow = [sessionsView selectedRow];
	
	NSDate *stDate = [NSDate date];
	
	//convert date to hours:minute:seconds string, then back to date
	//alleviates problem with editing the date object in list view
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%H:%M:%S" allowNaturalLanguage:NO];
	
	NSString *HHMMSS=[dateFormatter stringFromDate:stDate];
	NSDate *stTime = [dateFormatter dateFromString:HHMMSS];
	
	uSession = [arrSessions objectAtIndex:selRow];
	NSDate *theStartTime = [uSession startTime];
	
	if (theStartTime == nil){ 
		[uSession setStartTime:stTime];
		[selCell setTarget:self];
		desiredColumn = [sessionsView tableColumnWithIdentifier:@"startClock"];
		[desiredColumn setDataCell:selCell];
	}else{
		[uSession setEndTime:stTime];
		[selCell setTarget:self];
		desiredColumn = [sessionsView tableColumnWithIdentifier:@"startClock"];
		[desiredColumn setDataCell:selCell];
	}
	
	[self newSessionButtons:uSession :0];//to reset buttons to unpressed state only.
	//[sessionsView reloadData];

		//add notification to save
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"BNRDataAdded" object:self];
		
	//Logs
	NSString *tString;
	tString = [NSString stringWithFormat:@"%ld", (long)[selCell state]];
	//NSLog(@"Button State = %@",tString);
}

//Show notes input sheet(window)
- (IBAction)raiseNotesWindow:(id)sender
{
	if ([self getSelTabIndex]==2){
	int selRow = [sessionsView selectedRow];
	Session *uSession = [arrSessions objectAtIndex:selRow];
	[txtNotesEntry setString:[uSession txtNotes]];
	
	[NSApp beginSheet:notesWindow 
	   modalForWindow:[mainTabView window] 
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
	} else if([self getSelTabIndex]==3) {
		int selRow1 = [allSessionsView selectedRow];
		Session *uSession1 = [storedSessions objectAtIndex:selRow1];
		[txtNotesEntry setString:[uSession1 txtNotes]];
		
		[NSApp beginSheet:notesWindow 
		   modalForWindow:[mainTabView window] 
			modalDelegate:self
		   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			  contextInfo:NULL];
	}
}
- (IBAction)endNotesWindow:(id)sender
{
	//hide sheet
	[notesWindow orderOut:sender];
	
	//return to normal event handling
	[NSApp endSheet:notesWindow returnCode:1];
}

- (void)sheetDidEnd:(NSWindow *)sheet
		 returnCode:(int)returnCode
		contextInfo:(void *)contextInfo
{
	if ([self getSelTabIndex]==4){
		
		NSLog(@"Invoice sheet");
		
	}else{
		if ([self getSelTabIndex]==2){
			//Add notes to current session object
			int selRow = [sessionsView selectedRow];
			Session *uSession = [arrSessions objectAtIndex:selRow];
			[uSession setTxtNotes:[txtNotesEntry string]];
			} else {
			//Add notes to stored session object
			int selRow = [allSessionsView selectedRow];
			Session *uSession = [storedSessions objectAtIndex:selRow];
			[uSession setTxtNotes:[txtNotesEntry string]];	
		}
		
	}
	NSLog(@"sheet ended: code = %d", returnCode);
}

- (IBAction)raiseInvoiceWindow:(id)sender
{

	if ([self getSelTabIndex]==4){
		int selRow = [invoicesView selectedRow];
		Invoice *uInvoice = [arrInvoices objectAtIndex:selRow];
		
		NSString     * path        = [self pathForDataFile:4];
		NSDictionary * rootObject;
		rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
		
        NSMutableArray *arrProfiles = [[NSMutableArray alloc] initWithArray: [rootObject valueForKey:@"profile"]];
        
		
        
		if ([arrProfiles count] == 0){
            
            int validateAction;
            validateAction = NSRunAlertPanel(NSLocalizedString(@"profCheck", @"profCheck"), NSLocalizedString(@"profCheckMsg", @"profCheckMsg"),NSLocalizedString(@"0K", @"OK"), nil, nil);
            
    
            
		}else{
			Profile *uProfile;
            [arrProfiles autorelease];
            uProfile = [arrProfiles objectAtIndex:0];
            
            //profile data
            NSString *emptystr = [[NSString alloc] initWithString:@""];
            if ([[uProfile profileName] isEqual: emptystr]){
                int validateAction;
                validateAction = NSRunAlertPanel(NSLocalizedString(@"profCheck", @"profCheck"),NSLocalizedString(@"profNameCheckMsg", @"profNameCheckMsg"), NSLocalizedString(@"0K", @"OK"), nil, nil);
            }
            [txtMyName setStringValue:[uProfile profileName]];
            [txtMyAddress setStringValue:[uProfile profileAddress]];
            [txtMyCity setStringValue:[uProfile profileCity]];
            [txtMyState setStringValue:[uProfile profileState]];
            [txtMyZip setStringValue:[uProfile profileZip]];
            [txtMyPhone setStringValue:[uProfile profilePhone]];
            
            
            //client data
            int i;
            [txtInvoiceNumber setStringValue:[uInvoice invoiceNumber]];
            [txtClientName setStringValue:[uInvoice clientName]];
            NSString *x = [[NSString alloc] init];
            NSString *y = [[NSString alloc] init];
            x = [uInvoice clientID];
            
            for (i=0;i < [arrClients count]; i++){
                y = [[arrClients objectAtIndex:i] clientID]; ;
                if ([x isEqual: y]){
                    [txtClientAddress setStringValue:[[arrClients objectAtIndex:i] streetAddress]];
                [txtClientCity setStringValue:[[arrClients objectAtIndex:i] city]];
                [txtClientState setStringValue:[[arrClients objectAtIndex:i] state]];
                [txtClientZip setStringValue:[[arrClients objectAtIndex:i] postalCode]];
                }
            }

            [txtApprovedBy setStringValue:[uInvoice approvalName]];
            [txtTerms setStringValue:[uInvoice invoiceTerms]];
            [txtProjectName setStringValue:[uInvoice projectName]];

            [txtServices setString:[uInvoice invoiceNotes]];
            
            [txtMaterials setString:[uInvoice invoiceMaterials]];
            [txtHours setStringValue:[uInvoice totalTime]];

            [txtRate setStringValue:[uInvoice SinvoiceRate]];
            [txtSubTotal setStringValue:[uInvoice StotalDue]];
            [txtMaterialsTotal setStringValue:[uInvoice SmaterialsTotal]];
            [txtDeposit setStringValue:[uInvoice SinvoiceDeposit]];
            [txtTotalDue setStringValue:[uInvoice SgrandTotal]];
            [txtCheckNumber setStringValue:[uInvoice checkNumber] ];
            
            
            //get current date format
            NSDateFormatter *dateFormatter;
            
            if ([self getDateFormatSetting]==1){
                dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%d/%m/%y"allowNaturalLanguage:NO];
            }else{
                dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%y"allowNaturalLanguage:NO];
            }
            
            NSDate *invDate = [uInvoice invoiceDate];
            NSString *MDY=[dateFormatter stringFromDate:invDate];
            
            @try{
                
                [txtInvoiceDate setStringValue:MDY];
            }
            @catch(NSException *exception)
            {
                
                //[txtInvoiceDate setStringValue:invDate];
            }
            
            NSDate *stDate = [uInvoice startDate];
            MDY=[dateFormatter stringFromDate:stDate];
            
            @try{
                [txtStartDate setStringValue:MDY];
            }
            @catch(NSException *exception)
            {
                //[txtStartDate setStringValue:stDate];
            }
            
            NSDate *endDate = [uInvoice endDate];
            MDY=[dateFormatter stringFromDate:endDate];
            @try{
            [txtEndDate setStringValue:MDY];
            }
            @catch(NSException *exception)
            {
                //[txtEndDate setStringValue:endDate];
            }
            
            //insert invoice image
            NSString *settingsPath = [[NSBundle bundleWithIdentifier: @"com.primomedia.TrackAndBill"] pathForResource:@"tbSettings" ofType:@"plist"];
            NSMutableDictionary * settingsDict;
            settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
            
            NSImage *invImage=[[NSImage alloc] initByReferencingFile:[settingsDict objectForKey:@"invoiceImage"]];
            
            [invoiceImageDisplay setImage:invImage];
            
            
            [NSApp beginSheet:invoiceWindow 
               modalForWindow:[mainTabView window] 
                modalDelegate:self
               didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                  contextInfo:NULL];
            
            [uProfile release];
        }
	}
}
- (IBAction)endInvoiceWindow:(id)sender
{
	//save changes
	int selRow = [invoicesView selectedRow];
	Invoice *uInvoice = [arrInvoices objectAtIndex:selRow];
	[uInvoice setInvoiceNotes:[txtServices string]];
	[uInvoice setInvoiceMaterials:[txtMaterials string]];

	
	//hide sheet
	[invoiceWindow orderOut:sender];
	
	//return to normal event handling
	[NSApp endSheet:invoiceWindow returnCode:1];
}
	
	

// Add button cell objects to list(start clock, text notes, audio notes)
- (void)newSessionButtons:(id)tSession :(int)type
{
	NSTableColumn *desiredColumn;
	NSButtonCell *cell;


	//clock button
	cell = [[NSButtonCell alloc] init];
	[cell setButtonType:NSMomentaryPushInButton];
	[cell setBezelStyle:NSTexturedSquareBezelStyle];
	[cell setTitle:@"Set"];
	[cell setAction:@selector(startClockTimer:)];
	[cell setTarget:self];
	
	desiredColumn = [sessionsView tableColumnWithIdentifier:@"startClock"];
	[desiredColumn setDataCell:cell];
	[cell release];
	
	if (type==1){
	//notes button-current sessions
	cell = [[NSButtonCell alloc] init];
	[cell setButtonType:NSMomentaryLightButton];
	[cell setBezelStyle:NSTexturedSquareBezelStyle];
	[cell setTitle:NSLocalizedString(@"notesButtonLabel", @"notesButtonLabel")];
	[cell setAction:@selector(raiseNotesWindow:)];
	[cell setTarget:self];
	
	
	desiredColumn = [sessionsView tableColumnWithIdentifier:@"textNotes"];
	[desiredColumn setDataCell:cell];
	[cell release];
	
	}else{
	//notes button-all sessions list
	cell = [[NSButtonCell alloc] init];
	[cell setButtonType:NSMomentaryLightButton];
	[cell setBezelStyle:NSTexturedSquareBezelStyle];
	[cell setTitle:NSLocalizedString(@"notesButtonLabel", @"notesButtonLabel")];
	[cell setAction:@selector(raiseNotesWindow:)];
	[cell setTarget:self];
	
	desiredColumn = [allSessionsView tableColumnWithIdentifier:@"textNotes"];
	[desiredColumn setDataCell:cell];
	[cell release];
	}

	//add client and project drop-down menu if quick timer session.
/*
	
	if (type==1){
		NSComboBoxCell *cellPU;
		cellPU = [[NSComboBoxCell alloc] init];
		[cellPU setControlSize:NSMiniControlSize];

		//set projects as the data source for the combo box	
		int i;
		for (i=0;i<[arrClients count];i++){
			Client *nClient = [arrClients objectAtIndex:i];
			[cellPU addItemWithObjectValue:[nClient company]];
		}
		[cellPU setFont:[NSFont userFontOfSize:9.5]];
		[cellPU setTarget:self];
		desiredColumn = [sessionsView tableColumnWithIdentifier:@"clientName"];
		[desiredColumn  setDataCell:cellPU];
		[cellPU release];
	
		cellPU = [[NSComboBoxCell alloc] init];
		[cellPU setControlSize:NSMiniControlSize];
	
		for (i=0;i<[arrProjects count];i++){
			Project *nProj = [arrProjects objectAtIndex:i];
			[cellPU addItemWithObjectValue:[nProj projectName]];
		}
		[cellPU setFont:[NSFont userFontOfSize:9.5]];
		[cellPU setTarget:self];
		desiredColumn = [sessionsView tableColumnWithIdentifier:@"projectName"];
		[desiredColumn  setDataCell:cellPU];
		[cellPU release];
	}
*/
	

}

- (IBAction)promptQTchange:(id)sender
{
	int err;
	int i,z,j;
	 if ([self getSelTabIndex] == 2){
		 for (i=0;i<[arrSessions count];i++){
			 
			Session *tSession = [arrSessions objectAtIndex:i];
			
			 if(![[tSession clientName] isEqual: @""] && ![[tSession projectName] isEqual: @""]){
				 
				 if(![tSession projectIDref]){ //save if no project id exists
					 
					// err = NSRunAlertPanel(@"Save Session", @"Would you like to save the selected quick timer session/s?", @"Yes", @"No", @"Cancel");
					 Project *nProject = [[Project alloc] init];
					 //Client *nClient =[[Client alloc] init];
					 
					 //selected client and project names
					 NSString *sClientName = [[NSString alloc] initWithString:[tSession clientName]];
					 NSString *sProjectName= [[NSString alloc] initWithString:[tSession projectName]];
					 
					 //get project id for selected projectname
					 for(z=0;z<[arrProjects count];z++){
						 nProject = [arrProjects objectAtIndex:z];
						 if([[nProject projectName] isEqual:sProjectName] && [[nProject clientName] isEqual:sClientName]){
							 [tSession setProjectIDref:[nProject projectID]];//set correct project id
							 [tSession setProjectName:[nProject projectName]];
							 [tSession setClientName:[nProject clientName]];
							
							 
							 for(j=0;j<[storedSessions count];j++){
								 Session *stSess=[storedSessions objectAtIndex:j];
								 if([[stSess sessionID] isEqual:[tSession sessionID]]){
									 [stSess setProjectIDref:[tSession projectIDref]];
									 break;
								 }
								 
							 }
							 
							 NSLog(@"QT session end time %@",[tSession endTime]);
							 break;
						 }
					 }
					 
				 }
				 
			 }else{
				 
				 err = NSRunAlertPanel(NSLocalizedString(@"saveSess", @"saveSess"), NSLocalizedString(@"saveSessMsg", @"saveSessMsg"), NSLocalizedString(@"sOK", @"sOK"), nil, nil);
				 
			 }
				 
			}
	 
	 }
	
}

//Begin quick timer session
- (IBAction)quickTimerStart:(id)sender
{
	Session *nSession = [[Session alloc] init];

		[nSession setStartTime:[NSDate date]];
		[nSession setSessionID:[self createRandomID]];
		[nSession setProjectIDref:nil];
		
		//add buttons
		[self newSessionButtons:nSession :1];
	
		
		[arrSessions addObject:nSession];//for viewing
		[storedSessions addObject:nSession];//for storage
				
		//Logs
		int rCount = [arrSessions count];
		NSString *tString;
		tString = [NSString stringWithFormat:@"%d", rCount];
		NSLog(@"Sessions count = %@",tString);
				
		[sessionsView reloadData];
				
		[self viewSelectedSessions];
		//change tab
		NSTabViewItem *selItem = [mainTabView tabViewItemAtIndex:2];
		[mainTabView selectTabViewItem: selItem];		
				
		[nSession release];
}

- (IBAction)addSession:(id)sender
{
	Session *nSession = [[Session alloc] init];
	Project *selProject = [[Project alloc] init];
	NSString *selProjName;
	NSString *selClient;
	int err;
	int selRow = [tableView selectedRow]; //projects table selected row
	
	if (selRow >=0) {
	
		selProject = [arrProjects objectAtIndex:selRow];
		selProjName = [selProject projectName];
		selClient = [selProject clientName];
		
		[nSession setProjectName:selProjName];
		[nSession setClientName:selClient];
		[nSession setProjectIDref:[selProject projectID]];
		[nSession setSessionID:[self createRandomID]];
	
		//add buttons
		[self newSessionButtons:nSession :1];
		
		
		[arrSessions addObject:nSession];//for viewing
	   [storedSessions addObject:nSession];//for storage
		
		//Logs
		int rCount = [arrSessions count];
		NSString *tString;
		tString = [NSString stringWithFormat:@"%d", rCount];
		NSLog(@"Sessions count = %@",tString);
		
		[sessionsView reloadData];

		[self viewSelectedSessions];
		//change tab
		NSTabViewItem *selItem = [mainTabView tabViewItemAtIndex:2];
		[mainTabView selectTabViewItem: selItem];		
		
	} else {
		err = NSRunAlertPanel(NSLocalizedString(@"selProject", @"selProject"), NSLocalizedString(@"selProjSession", @"selProjSession"), NSLocalizedString(@"sOK", @"sOK"), nil, nil);
		[selProject release];
	}
	
	[nSession release];
	
}

- (IBAction) addProject:(id)sender
{
	
	Project *nProject = [[Project  alloc] init];
	Client *selClient = [[Client alloc] init];
	NSString *selCompany;
	int err;
	int selRow = [clientsView selectedRow]; 
	
	if (selRow >=0) {
		selClient = [arrClients objectAtIndex:selRow];
		selCompany = [selClient company];
		
		[nProject setClientName:selCompany];
		[nProject setProjectID:[self createProjectID]];
		[nProject setClientID:[selClient clientID]];
		//[nProject setTotalTime:@"0"];
		[arrProjects addObject:nProject];
		
		//check project id

		
		//logs
		int rCount = [arrProjects count];
		NSString *tString;
		tString = [NSString stringWithFormat:@"%d", rCount];
		NSLog(@"project count = %@",tString);
		
		[tableView reloadData]; //tableView is projects list

		//change tab
		NSTabViewItem *selItem = [mainTabView tabViewItemAtIndex:1];
		[mainTabView selectTabViewItem: selItem];
	} else {
		err = NSRunAlertPanel(NSLocalizedString(@"selClient", @"selClient"), NSLocalizedString(@"selClientMsg", @"selClientMsg"),NSLocalizedString(@"sOK", @"sOK"), nil, nil);
		[selClient release];
	}
	[nProject release];
}

- (void)setDateFormat

{
	/////////////////
	@try{
		
		NSTableColumn *dateCol = [[NSTableColumn alloc] init];
		
		[dateCol setTableView:tableView];
		[dateCol setIdentifier:[[tableView tableColumns] objectAtIndex:2]];
		NSString *formatString;
		
		if ([self getDateFormatSetting]==1){
			formatString = @"%d/%m/%Y";
		}else{
			formatString = @"%m/%d/%Y";
		}
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] initWithDateFormat:formatString allowNaturalLanguage:NO];
		[[dateCol dataCell] setFormatter:dateFormat];
				
		//NSLog(@"COLUMN FORMATTER ========  %@",[[[dateCol dataCell] formatter] dateFormat] );
			
			//NSLog(@"COLUMMMMMNNNNN ::::: %d", [[tableView tableColumns] count]);
	}@catch (NSException *exception) {
		//NSLog(@"main: Caught %@: %@", [exception name], [exception  reason]);
		
	}
////////////////////
	
}

- (int)getDateFormatSetting
{
	NSString *settingsPath = [[NSBundle bundleWithIdentifier: @"com.primomedia.TrackAndBill"] pathForResource:@"tbSettings" ofType:@"plist"];
	NSMutableDictionary * settingsDict;
	settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	
	NSLog(@"date format is = %d",[[settingsDict objectForKey:@"dateFormat"] intValue] );
	
	return [[settingsDict objectForKey:@"dateFormat"] intValue] ;
	
}

- (int)getSelTabIndex
{
	NSTabViewItem *selItem = [mainTabView selectedTabViewItem];
	int selTab = [mainTabView indexOfTabViewItem:selItem];

	return selTab;
}

- (IBAction)deleteSession:(id)sender
{
	int validateAction;
	int i;
	NSString *x;
	NSString *y;
	
	validateAction = NSRunAlertPanel(NSLocalizedString(@"delSess", @"delSess"),NSLocalizedString(@"delSessConfirm", @"delSessConfirm"), NSLocalizedString(@"sYes", @"sYes"), NSLocalizedString(@"sNo", @"sNo"), NSLocalizedString(@"Cancel", @"Cancel"));
	
	if (validateAction == 1){
		
		if ([self getSelTabIndex] == 2){
			//determine selected row
			NSIndexSet *rows =[sessionsView selectedRowIndexes];
			
			//check if any rows are selected
			if ([rows count] > 0) {
				unsigned int row = [rows lastIndex];
				
				//remove selected rows
				
				//while (row != NSNotFound){
					//remove from stored list
					//search stored sessions for matching session id.
					x = [[NSString alloc] initWithString:[[arrSessions objectAtIndex:row] sessionID]];
					for (i=0; i<[storedSessions count];i++){
		
                        @try
                        {
                            y=[[NSString alloc] initWithString:[[storedSessions objectAtIndex:i] sessionID]];
                            if ([x isEqual:y]){
                                [storedSessions removeObjectAtIndex:i];
                            }
                            
                            [arrSessions removeObjectAtIndex:row];
                            row =[rows indexLessThanIndex:row];
                        
                        }@catch (NSException *exception) {
                            NSLog(@"main: Caught %@: %@", [exception name], [exception  reason]);
                            
                        }
                        
					}
				
				//}
				
				[sessionsView reloadData];
				[self viewSelectedSessions];
                
			}else{
				NSBeep();
			}
		}
	}
}
- (IBAction)deleteStoredSession:(id)sender
{
	int validateAction;
	

	validateAction = NSRunAlertPanel(NSLocalizedString(@"delSess", @"delSess"),NSLocalizedString(@"delSessConfirm", @"delSessConfirm"), NSLocalizedString(@"sYes", @"sYes"), NSLocalizedString(@"sNo", @"sNo"), NSLocalizedString(@"Cancel", @"Cancel"));
	
	
	if (validateAction == 1){
		
		if ([self getSelTabIndex] == 3){
			//determine selected row
			NSIndexSet *rows =[allSessionsView selectedRowIndexes];
			
			//check if any rows are selected
			if ([rows count] > 0) {
				unsigned int row = [rows lastIndex];
				
				//remove selected rows
				//while (row != NSNotFound){
					//remove from stored list
					[storedSessions removeObjectAtIndex:row];
					row =[rows indexLessThanIndex:row];
				//}
				[self viewSelectedSessions];
				[allSessionsView reloadData];

			}else{
				NSBeep();
			}
		}
	}
}

- (IBAction)clearSessions:(id)sender
{
	if ([self getSelTabIndex] == 2){
		//determine selected row
		NSIndexSet *rows =[sessionsView selectedRowIndexes];
		
		//check if any rows are selected
		if ([rows count] > 0) {
			unsigned int row = [rows lastIndex];
			
			//remove selected rows
			//while (row != NSNotFound){

				[arrSessions removeObjectAtIndex:row];
				row =[rows indexLessThanIndex:row];
			//}
			
			[sessionsView reloadData];

		}else{
			NSBeep();
		}
	}
	
}
- (IBAction)deleteProject:(id)sender
{
	int validateAction;
	
	validateAction = NSRunAlertPanel(NSLocalizedString(@"delProj", @"delProj"), NSLocalizedString(@"delProjConfirm", @"delProjConfirm"), NSLocalizedString(@"sYes", @"sYes"), NSLocalizedString(@"sNo", @"sNo"),NSLocalizedString(@"Cancel", @"Cancel"));
	
	if (validateAction == 1){
		
		if ([self getSelTabIndex] == 1){
			//determine selected row
			NSIndexSet *rows =[tableView selectedRowIndexes];
		
			//check if any rows are selected
			if ([rows count] > 0) {
				unsigned int row = [rows lastIndex];
			
				//remove selected rows
				//while (row != NSNotFound){
					[arrProjects removeObjectAtIndex:row];
					row =[rows indexLessThanIndex:row];
				//}
				[tableView reloadData];
			}else{
				NSBeep();
			}
		
		}
	}
}

- (IBAction)deleteClient:(id)sender
{
	int validateAction;
	
	validateAction = NSRunAlertPanel(NSLocalizedString(@"delClient", @"delClient"), NSLocalizedString(@"delClientConfirm", @"delClientConfirm"), NSLocalizedString(@"sYes", @"sYes"), NSLocalizedString(@"sNo", @"sNo"), NSLocalizedString(@"Cancel", @"Cancel"));
	
	if (validateAction == 1){
			
		if ([self getSelTabIndex] == 0){
			//determine selected row
			NSIndexSet *rows =[clientsView selectedRowIndexes];
			
			//check if any rows are selected
			if ([rows count] > 0) {
				unsigned int row = [rows lastIndex];
				
				//remove selected rows
				//while (row != NSNotFound){
					[arrClients removeObjectAtIndex:row];
					row =[rows indexLessThanIndex:row];
				//}
				[clientsView reloadData];
			}else{
				NSBeep();
			}
		}
	}
}


- (IBAction)addClient:(id)sender
{
	
	Client *nClient = [[Client alloc] init];
	[arrClients addObject:nClient];
	[nClient setClientID:[self createRandomID]];
	
	int rCount = [arrClients count];
	NSString *tString;
	tString = [NSString stringWithFormat:@"%d", rCount];
	
	NSLog(@"clients count = %@",tString);
	
	[clientsView reloadData];
	
	//change tab
	NSTabViewItem *selItem = [mainTabView tabViewItemAtIndex:0];
	[mainTabView selectTabViewItem: selItem];
	
	[nClient release];
}

- (void)willTerminate:(NSNotification *)notif
{
	//add notification to save
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"BNRDataAdded" object:self];
}

//tab view item has changed
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if ([self getSelTabIndex] == 1){
	
			[self computeTotalTime];
		
	}
	
}



- (int)numberOfRowsInTableView:(NSTableView *)atableView
{
	
	//add notification to save
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"BNRDataAdded" object:self];

	switch ([self getSelTabIndex]) //get selected tab view index
	{
		case 0:{
			int rCount = [arrClients count];
			NSString *tString;
			tString = [NSString stringWithFormat:@"%d", rCount];
			NSLog(@"Row Count = %@", tString);
			return [arrClients count];
		}
			
		case 1:{
			int rCount = [arrProjects count];
			NSString *tString;
			tString = [NSString stringWithFormat:@"%d", rCount];
			NSLog(@"Row Count = %@", tString);
			return [arrProjects count];
		}
		case 2:{
			int rCount = [arrSessions count];
			NSString *tString;
			tString = [NSString stringWithFormat:@"%d", rCount];
			NSLog(@"Row Count = %@", tString);
			return [arrSessions count];
		}
		case 3:{
			int rCount = [selSessions count];
			NSString *tString;
			tString = [NSString stringWithFormat:@"%d", rCount];
			NSLog(@"Row Count = %@", tString);
			return [selSessions count];
		}
		case 4:{
			int rCount = [arrInvoices count];
			NSString *tString;
			tString = [NSString stringWithFormat:@"%d", rCount];
			NSLog(@"Row Count = %@", tString);
			return [arrInvoices count];
		}
			
	}
	return 0;
}


//Loads table views

- (id)tableView:(NSTableView *)atableView objectValueForTableColumn:(NSTableColumn *)tableViewColumn row:(int)rowIndex
{
	switch ([self getSelTabIndex])
	{
		case 0:{
	NSString *identifier =[tableViewColumn identifier];//identifier for the column(set in Interface builder)
	Client *nClient = [arrClients objectAtIndex:rowIndex];
	return [nClient valueForKey:identifier];//value of the attribute named identifier
		}

		case 1:{
	NSString *identifier =[tableViewColumn identifier];
	Project *nProject = [arrProjects objectAtIndex:rowIndex];
	return [nProject valueForKey:identifier];
		}
		case 2:{
	NSString *identifier =[tableViewColumn identifier];
	Session *nSession = [arrSessions objectAtIndex:rowIndex];
	return [nSession valueForKey:identifier];
		}
		case 3:{
	 NSString *identifier =[tableViewColumn identifier];
	Session *nSession = [selSessions objectAtIndex:rowIndex];
	//add buttons on tab selection
	[self newSessionButtons:nSession :0];
	return [nSession valueForKey:identifier];

		}
	case 4:{
			NSString *identifier =[tableViewColumn identifier];
			Invoice *nInvoice = [arrInvoices objectAtIndex:rowIndex];
			return [nInvoice valueForKey:identifier];
		}

}
return nil;
}

- (void)tableView:(NSTableView *)atableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
	switch ([self getSelTabIndex])
	{
		case 0:{
			NSString *identifier = [tableColumn identifier];//identifier for the column(set in Interface builder)
			Client *nClient = [arrClients objectAtIndex:rowIndex];
			[nClient setValue:anObject forKey:identifier];//value of the attribute named identifier
				break;
		}
			
		case 1:{
			NSString *identifier = [tableColumn identifier];
			Project *nProject = [arrProjects objectAtIndex:rowIndex];
			[nProject setValue:anObject forKey:identifier];
			break;
		}
		case 2:{
			NSString *identifier = [tableColumn identifier];
			Session *nSession = [arrSessions objectAtIndex:rowIndex];
			[nSession setValue:anObject forKey:identifier];
			break;
		}
		case 3:{
			NSString *identifier = [tableColumn identifier];
			Session *naSession = [selSessions objectAtIndex:rowIndex];
			[naSession setValue:anObject forKey:identifier];
			break;
		}
		case 4:{
			NSString *identifier = [tableColumn identifier];
			Invoice *nInvoice = [arrInvoices objectAtIndex:rowIndex];
			[nInvoice setValue:anObject forKey:identifier];
			[nInvoice computeTotalDue];
			break;
		}
	}

}


//////////////////////////////////////////
// Save data
//////////////////////////////////////////
- (NSString *) pathForDataFile:(int)sFile
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/TrackAndBill_OSX"; //destination folder
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO)
	{
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
		//[fileManager createDirectoryAtPath: folder attributes: nil];
	}
	
	switch (sFile){
		case 0:{
			NSString *fileName = @"clients.tbd"; //new file name
			return [folder stringByAppendingPathComponent: fileName];
		}
		case 1:{
			NSString *fileName = @"projects.tbd"; //new file name
			return [folder stringByAppendingPathComponent: fileName]; 
		}
		case 2:{
			NSString *fileName = @"sessions.tbd"; //new file name
			return [folder stringByAppendingPathComponent: fileName]; 
		}
		case 3:{
			NSString *fileName = @"invoices.tbd"; //new file name
			return [folder stringByAppendingPathComponent: fileName]; 
		}
		case 4: {
			
			NSString *fileName = @"profiles.tbd"; //new file name
			return [folder stringByAppendingPathComponent: fileName]; 
			
		}
	}
	return nil;
}

// Save
- (void) saveDataToDisk:(int)sFile
{
	NSMutableDictionary * rootObject;
	rootObject = [NSMutableDictionary dictionary];

	switch (sFile){
		case 0:{
			NSString *path = [self pathForDataFile:0];
			[rootObject setValue: [self arrClients] forKey:@"clients"];
			[NSKeyedArchiver archiveRootObject: rootObject toFile: path];
			break;
		}
		case 1:{
			NSString *path = [self pathForDataFile:1];
			[rootObject setValue: [self arrProjects] forKey:@"projects"];
			[NSKeyedArchiver archiveRootObject: rootObject toFile: path];
	break;
		}
		case 2:{
			NSString *path = [self pathForDataFile:2];
			[rootObject setValue: [self storedSessions] forKey:@"sessions"];
			[NSKeyedArchiver archiveRootObject: rootObject toFile: path];
			break;
		}
		case 3:{
			NSString *path = [self pathForDataFile:3];
			[rootObject setValue: [self arrInvoices] forKey:@"invoices"];
			[NSKeyedArchiver archiveRootObject: rootObject toFile: path];
			break;
		}
	}
	
	int rCount = [storedSessions count];
	NSString *tString;
	tString = [NSString stringWithFormat:@"%d", rCount];
	
	NSLog(@"File Saved, saved Sessions = %@", tString);
}


- (void)saveData:(NSNotification *)note
{
	NSLog(@"Received notification(save): %@", note);
	//save all objects
	[self saveDataToDisk:0];
	[self saveDataToDisk:1];
	[self saveDataToDisk:2];
	[self saveDataToDisk:3];
}

////////////////////////////////////////////////////////////////////////////////////////////////
//// Load data from file
//////////////////////////

- (void) loadDataFromDisk:(int)sFile
{
	@try
	{
	switch (sFile){
		case 0:{
	NSString  *path= [self pathForDataFile:0];
	NSDictionary *rootObject;
	rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
	[self setClients: [rootObject valueForKey:@"clients"]];
	break;
	}
		case 1:{
	NSString *path = [self pathForDataFile:1];
	NSDictionary *rootObject;
	rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
	[self setProjects: [rootObject valueForKey:@"projects"]];
	break;
		}
		case 2:{
	NSString *path = [self pathForDataFile:2];
	NSDictionary *rootObject;
	rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
	[self setStoredSessions: [rootObject valueForKey:@"sessions"]];
	break;
		}	
		case 3:{
	NSString * path= [self pathForDataFile:3];
	NSDictionary * rootObject;
	rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
	[self setInvoices: [rootObject valueForKey:@"invoices"]];
	break;
		}
	}
	}@catch (NSException *exception) {
		NSLog(@"main: Caught %@: %@", [exception name], [exception  reason]);
		
	}
}


//initialize array objects with stored data
- (void) setProjects: (NSArray *)newProjects
{
    if (arrProjects != newProjects)
    {

		
        [arrProjects autorelease];
        arrProjects = [[NSMutableArray alloc] initWithArray: newProjects];
		[tableView reloadData];

	
		
    }
}

- (void) setClients: (NSArray *)newClients
{
    if (arrClients != newClients)
    {
        [arrClients autorelease];
        arrClients = [[NSMutableArray alloc] initWithArray: newClients];
		[clientsView reloadData];
    }
}
- (void) setSessions: (NSArray *)newSessions
{
    if (arrSessions != newSessions)
    {
        [arrSessions autorelease];
        arrSessions = [[NSMutableArray alloc] initWithArray: newSessions];
		[sessionsView reloadData];
    }
}

- (void) setStoredSessions: (NSArray *)newSessions
{
    if (storedSessions != newSessions)
    {
        [storedSessions autorelease];
        storedSessions = [[NSMutableArray alloc] initWithArray: newSessions];
		selSessions = [[NSMutableArray alloc] initWithArray:storedSessions];
		[allSessionsView reloadData];
    }
}

- (void) setInvoices: (NSArray *)newInvoices
{
    if (arrInvoices != newInvoices)
    {
        [arrInvoices autorelease];
        arrInvoices = [[NSMutableArray alloc] initWithArray: newInvoices];
		[invoicesView reloadData];
    }
}

- (IBAction)print:(id)sender
{
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	[printInfo setTopMargin:0.1];
	[printInfo setLeftMargin:1.0];
	[printInfo setRightMargin:1.0];
	NSPrintOperation *printOp;
	NSView *v= invoiceBox;
	printOp = [NSPrintOperation printOperationWithView:v
											 printInfo:printInfo];
    [printOp setShowsPrintPanel:YES];
	//[printOp setShowPanels:YES];
	[printOp runOperation];
}

- (IBAction)showPreferenceController:(id)sender
{
	if (!preferenceController){
		preferenceController = [[PreferenceController alloc] init];
	}	
	[preferenceController showWindow:self];
	

}

- (IBAction) openPrimoSite:(id)sender

{
	NSString *stringURL = @"http://loudsoftware.com";
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:stringURL]];
	

}

- (IBAction) appHelpLink:(id)sender
{
	NSString *stringURL = @"http://primo-media.com/helpFiles/BTSTBmac_help/help_frameset.htm";	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:stringURL]];
}


- (IBAction)exportProjectSessions:(id)sender
{
	Project *selProject = [[Project alloc] init];

	bool result;
	int err;
	int selRow = [tableView selectedRow]; //projects table selected row
	
	if (selRow >=0) {
		
		selProject = [arrProjects objectAtIndex:selRow];
		Session *iSession;
		int i;
		int panelVal;
		NSString *x = [[NSString alloc] init];
		NSString *y = [[NSString alloc] init];

		
		NSString *formatString;
		
		if ([self getDateFormatSetting]==1){
			formatString = @"%d/%m/%Y";
		}else{
			formatString = @"%m/%d/%Y";
		}
		

		//show save dialog box, and set file path and name
		NSSavePanel * savePanel= [[NSSavePanel alloc] init];
		panelVal = [savePanel runModal];	
		
    
        NSURL *path = [savePanel URL];
		
		//NSLog(@"save csv path: %@", path);
		
		NSMutableArray * fileArray = [[NSMutableArray alloc] init];
		
		NSString * headerString;
		headerString = [NSString stringWithFormat:@",'Client','Project','Date','Start Time','End Time','Notes',"];
		[fileArray addObject:headerString];

		y = [selProject projectID];
		for (i=0;i<[storedSessions count]; i++){
			
			iSession = [storedSessions objectAtIndex:i];
			x = [iSession projectIDref];
			if ([x isEqual: y]){
				
				//create text file with delimiter
			
				NSString * rowString;
				rowString = [NSString stringWithFormat:@",'%@','%@','%@','%@','%@','%@',", 
					[iSession clientName],[iSession projectName],
					[iSession sessionDate],[iSession startTime],
					[iSession endTime],[iSession txtNotes]];
				
				[fileArray addObject:rowString];
				
			}
			
		}
		
	@try{
		//write to file
		result = [fileArray writeToFile:[path absoluteString] atomically:0];
		
	}@catch (NSException *exception) {
		//NSLog(@"main: Caught %@: %@", [exception name], [exception  reason]);
		
	}

	} else {
		err = NSRunAlertPanel(NSLocalizedString(@"selProject", @"selProject"), NSLocalizedString(@"selProjExport", @"selProjExport"), @"sOK", nil, nil);
		[selProject release];

	}
	

	
	
}



- (IBAction)exportSelectedSessions:(id)sender
{
	
	
}




 - (void)dealloc
 {
	 //int err;
	 //err = NSRunAlertPanel(@"Select project", @"Please select a project for your new session.", @"OK", nil, nil);
	 NSLog(@"dealloc called");
	 
	 [arrClients release];
	 [arrSessions release];
	 [arrProjects release];
	 [arrInvoices release];
	 [preferenceController release];
	 [super dealloc];
 }
@end
