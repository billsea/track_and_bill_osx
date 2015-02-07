//
//  Project.h
//  TrackAndBill_OSX
//
//  Created by Bill on 11/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Project : NSObject <NSCoding>{
	NSString *projectName;
	NSString *clientName;
	NSDate *startDate;
	NSDate *endDate;
	NSString *totalTime;
	NSString *projectID;
	NSString *clientID;
}

- (void)setProjectName:(NSString *)pName;
- (void)setClientName:(NSString *)cName;
- (void)setStartDate:(NSDate *)sDate;
- (void)setEndDate:(NSDate *)eDate;
- (void)setTotalTime:(NSString *)tTime;
- (void)setProjectID:(NSString *)pID;
- (void)setClientID:(NSString *)cID;
- (int)getDateFormatSetting;

@end
