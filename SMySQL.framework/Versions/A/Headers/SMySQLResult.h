//
//  SMySQLResult.h
//  SMySQL
//
//  Created by serge cohen (serge.cohen@m4x.org) on Sat Dec 08 2001.
//  Copyright (c) 2001 MySQL Cocoa project.
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This code is distributed in the hope that it will be useful, but WITHOUT ANY
//  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  For a copy of the GNU General Public License, visit <http://www.gnu.org/> or
//  write to the Free Software Foundation, Inc., 59 Temple Place--Suite 330,
//  Boston, MA 02111-1307, USA.
//
//  More info at <http://mysql-cocoa.sourceforge.net/>
//
// $Id: SMySQLResult.h,v 1.6 2002/05/15 11:07:30 sergecohen Exp $


#import <Foundation/Foundation.h>
#import "mysql.h"
//#import <SMySQL/mysql.h>
//#import <SMySQL/SMySQL.h>

//@class SMySQLRow;

@interface SMySQLResult : NSObject {
    MYSQL_RES		*mResult;	/*"The MYSQL_RES structure of the C API"*/
    NSArray		*mNames;	/*"An NSArray holding the name of the columns"*/
    NSDictionary	*mMySQLLocales;	/*"A Locales dictionary to define the locales of MySQL"*/
    NSStringEncoding	mEncoding;	/*"The encoding used by MySQL server, to ISO-1 default"*/
}

/*"
Init used #{only} by #{SMySQLConnection} 
"*/

- (id)initWithMySQLPtr:(MYSQL *)mySQLPtr encoding:(NSStringEncoding)theEncoding;
- (id)initWithResPtr:(MYSQL_RES *)mySQLResPtr encoding:(NSStringEncoding)theEncoding;
- (id)init;

/*"
General info on the result
"*/

- (my_ulonglong)numOfRows;
- (unsigned int)numOfFields;

/*"
Getting the rows
"*/

- (void)dataSeek:(my_ulonglong)row;

- (NSDictionary *)fetchRowAsDictionary;
- (NSArray *)fetchRowAsArray;

/*"
Getting information on columns
"*/

- (NSArray *)fetchFieldsName;

- (NSArray *)fetchTypesAsArray;
- (NSDictionary *)fetchTypesAsDictionary;

- (BOOL)isBlobAtIndex:(unsigned int)index;
- (BOOL)isBlobForKey:(NSString *)key;

/*"
Utility method
"*/
- (NSString *)description;

/*"
End of the scope...
"*/

- (void)dealloc;

/*"
Private methods, internam use only
"*/
- (const char *)cStringFromString:(NSString *)theString;
- (NSString *)stringWithCString:(const char *)theCString;

@end
