//
//  SMySQLConnection.h
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
// $Id: SMySQLConnection.h,v 1.10 2002/05/30 08:32:33 sergecohen Exp $


#import <Foundation/Foundation.h>
#import "mysql.h"
#import <SMySQL/mysql.h>
#import <SMySQL/SMySQL.h>

@class SMySQLResult;

#define kSMySQL_default_option CLIENT_COMPRESS
#define kSMySQLConnectionDefaultSocket MYSQL_UNIX_ADDR
#define kSMySQLConnection_error_not_inited 1000

@interface SMySQLConnection : NSObject {
    MYSQL		*mConnection;	/*"The inited MySQL connection"*/
    BOOL		mConnected;	/*"Reflect the fact that the connection is already in place or not"*/
    NSStringEncoding	mEncoding;	/*"The encoding used by MySQL server, to ISO-1 default"*/
//[DIFF]
    id			delegate;
}
/*"
Getting default of MySQL
"*/
+ (NSDictionary *) getMySQLLocales;
+ (NSStringEncoding) encodingForMySQLEncoding:(const char *) mysqlEncoding;
+ (NSStringEncoding) defaultMySQLEncoding;

/*"
Initialisation
"*/
- (id) init;
// Port to 0 to use the default port
- (id) initToHost:(NSString *) host withLogin:(NSString *) login password:(NSString *) pass usingPort:(int) port;
- (id) initToSocket:(NSString *) socket withLogin:(NSString *) login password:(NSString *) pass;

- (BOOL) setConnectionOption:(int) option withArgument:(id) arg;
// Port to 0 to use the default port
- (BOOL) connectWithLogin:(NSString *) login password:(NSString *) pass host:(NSString *) host port:(int) port socket:(NSString *) socket;

- (BOOL) selectDB:(NSString *) dbName;

/*"
Errors information
"*/

- (NSString *) getLastErrorMessage;
- (unsigned int) getLastErrorID;
- (BOOL) isConnected;
- (BOOL) checkConnection;

/*"
Queries
"*/

- (NSString *) prepareBinaryData:(NSData *) theData;
- (NSString *) prepareString:(NSString *) theString;

- (SMySQLResult *) queryString:(NSString *) query;

- (my_ulonglong) affectedRows;
- (my_ulonglong) insertId;


/*"
Getting description of the database structure
"*/
- (SMySQLResult *) listDBs;
- (SMySQLResult *) listDBsLike:(NSString *) dbsName;
- (SMySQLResult *) listTables;
- (SMySQLResult *) listTablesLike:(NSString *) tablesName;
// Next method uses SHOW TABLES FROM db to be sure that the db is not changed during this call.
- (SMySQLResult *) listTablesFromDB:(NSString *) dbName like:(NSString *) tablesName;
- (SMySQLResult *) listFieldsFromTable:(NSString *) tableName;
- (SMySQLResult *) listFieldsFromTable:(NSString *) tableName like:(NSString *) fieldsName;


/*"
Server information and control
"*/

- (NSString *) clientInfo;
- (NSString *) hostInfo;
- (NSString *) serverInfo;
- (NSNumber *) protoInfo;
- (SMySQLResult *) listProcesses;
- (BOOL) killProcess:(unsigned long) pid;

//- (BOOL)createDBWithName:(NSString *)dbName;
//- (BOOL)dropDBWithName:(NSString *)dbName;

/*"
Disconnection
"*/

- (void) disconnect;
- (void) dealloc;

/*"
String encoding concerns (c string type to NSString).
It's unlikely that users of the framework needs to use these methods which are used internally
"*/
- (void) setEncoding:(NSStringEncoding) theEncoding;
- (NSStringEncoding) encoding;

- (const char *) cStringFromString:(NSString *) theString;
- (NSString *) stringWithCString:(const char *) theCString;

//[DIFF]: delegate methods
- (void)setDelegate:(id)object;

@end
