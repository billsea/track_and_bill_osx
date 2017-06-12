//
//  Client.h
//  TrackAndBill_OSX
//
//  Created by Bill on 11/8/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Client : NSObject <NSCoding> {
  NSString *company;
  NSString *contactName;
  NSString *email;
  NSString *streetAddress;
  NSString *city;
  NSString *country;
  NSString *state;
  NSString *postalCode;
  NSString *phoneNumber;
  NSString *clientID;

}
- (void)setCompanyName:(NSString *)pCompany;
- (void)setContactName:(NSString *)pContact;
- (void)setEmail:(NSString *)pEmail;
- (void)setStreet:(NSString *)pStreet;
- (void)setCity:(NSString *)pCity;
- (void)setCountry:(NSString *)pCountry;
- (void)setState:(NSString *)pState;
- (void)setPostalCode:(NSString *)pPostal;
- (void)setPhoneNumber:(NSString *)pPhone;
- (void)setClientID:(NSString *)cID;

@end
