//
//  Session.m
//  TrackAndBill_OSX
//
//  Created by Bill on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Session.h"

@implementation Session

- (id)init {
  [super init];
  [self setProjectName:@""];
  [self setClientName:@""];

  NSDate *stTime = nil; //[NSDate date];
  [self setSessionDate:[NSDate date]];
  [self setStartTime:stTime];
  [self setEndTime:stTime];
  [self setTxtNotes:@""];

  return self;
}

- (NSString *)projectName {
  return projectName;
}

- (NSString *)projectIDref {
  return projectIDref;
}
- (NSString *)sessionID {
  return sessionID;
}

- (NSString *)clientName {
  return clientName;
}

- (NSString *)txtNotes {
  return txtNotes;
}

- (NSDate *)sessionDate {
  return sessionDate;
}

- (NSDate *)startTime {
  return startTime;
}
- (NSDate *)endTime {
  return endTime;
}
- (NSButtonCell *)startClock {
  return startClock;
}
- (NSButtonCell *)textNotes {
  return textNotes;
}

//////// Methods ////////
- (void)setProjectName:(NSString *)pName {
  pName = [pName copy];
  [projectName release];
  projectName = pName;
}
- (void)setProjectIDref:(NSString *)pIDref {
  pIDref = [pIDref copy];
  [projectIDref release];
  projectIDref = pIDref;
}
- (void)setClientName:(NSString *)cName {
  cName = [cName copy];
  [clientName release];
  clientName = cName;
}

- (void)setSessionDate:(NSDate *)sDate {
  sDate = [sDate copy];
  [sessionDate release];

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] autorelease];
  @try {
    if ([self getDateFormatSetting] == 1) {
      [dateFormatter initWithDateFormat:@"%d/%m/%y" allowNaturalLanguage:NO];
    } else {
      [dateFormatter initWithDateFormat:@"%m/%d/%y" allowNaturalLanguage:NO];
    }

    NSString *modString =
        [[NSString alloc] initWithString:[dateFormatter stringFromDate:sDate]];
    sessionDate = [[dateFormatter dateFromString:modString] copy];

  } @catch (NSException *exception) {
    NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
    sessionDate = sDate;
  }
}

- (void)setStartTime:(NSDate *)sTime {
  sTime = [sTime copy];
  [startTime release];
  startTime = sTime;
}
- (void)setEndTime:(NSDate *)eTime {
  eTime = [eTime copy];
  [endTime release];
  endTime = eTime;
}
- (void)setTxtNotes:(NSString *)tNotes {
  tNotes = [tNotes copy];
  [txtNotes release];
  txtNotes = tNotes;
}
- (void)setSessionID:(NSString *)sID {
  sID = [sID copy];
  [sessionID release];
  sessionID = sID;
}

- (int)getDateFormatSetting {
  NSString *settingsPath =
      [[NSBundle bundleWithIdentifier:@"com.primomedia.TrackAndBill"]
          pathForResource:@"tbSettings"
                   ofType:@"plist"];
  NSMutableDictionary *settingsDict;
  settingsDict =
      [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];

  NSLog(@"date format is = %d",
        [[settingsDict objectForKey:@"dateFormat"] intValue]);

  return [[settingsDict objectForKey:@"dateFormat"] intValue];
}

// Saving and loading data

// save
- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:projectName forKey:@"projectName"];
  [coder encodeObject:clientName forKey:@"clientName"];
  [coder encodeObject:sessionDate forKey:@"sessionDate"];
  [coder encodeObject:startTime forKey:@"startTime"];
  [coder encodeObject:endTime forKey:@"endTime"];
  [coder encodeObject:txtNotes forKey:@"txtNotes"];
  [coder encodeObject:projectIDref forKey:@"projectIDref"];
  [coder encodeObject:sessionID forKey:@"sessionID"];
}

// load from file
- (id)initWithCoder:(NSCoder *)coder {
  if (self = [super init]) {

    [self setProjectName:[coder decodeObjectForKey:@"projectName"]];
    [self setClientName:[coder decodeObjectForKey:@"clientName"]];
    [self setSessionDate:[coder decodeObjectForKey:@"sessionDate"]];
    [self setStartTime:[coder decodeObjectForKey:@"startTime"]];
    [self setEndTime:[coder decodeObjectForKey:@"endTime"]];
    [self setTxtNotes:[coder decodeObjectForKey:@"txtNotes"]];
    [self setProjectIDref:[coder decodeObjectForKey:@"projectIDref"]];
    [self setSessionID:[coder decodeObjectForKey:@"sessionID"]];
  }
  return self;
}

- (void)dealloc {

  [projectName release];

  [super dealloc];
}
@end
