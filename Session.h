//
//  Session.h
//  TrackAndBill_OSX
//
//  Created by Bill on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Session : NSObject <NSCoding> {

  NSString *projectName;
  NSString *clientName;
  NSDate *sessionDate;
  NSDate *startTime;
  NSDate *endTime;
  NSButtonCell *startClock;
  NSButtonCell *textNotes; // for text and audio notes
  NSString *txtNotes;
  NSString *projectIDref;
  NSString *sessionID;
}
- (void)setProjectName:(NSString *)pName;
- (void)setClientName:(NSString *)cName;
- (void)setSessionDate:(NSDate *)sDate;
- (void)setStartTime:(NSDate *)sTime;
- (void)setEndTime:(NSDate *)eTime;
- (void)setTxtNotes:(NSString *)tNotes;
- (void)setProjectIDref:(NSString *)pIDref;
- (void)setSessionID:(NSString *)sID;
- (int)getDateFormatSetting;

@end
