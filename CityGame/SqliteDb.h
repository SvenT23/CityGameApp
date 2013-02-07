//
//  SqliteDb.h
//  MapkitAppCitygame
//
//  Created by Wim on 29/01/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@interface SqliteDb : NSObject
{
    NSString        *databasePath;
    sqlite3 *db;
}

-(void)createDB;
-(void)saveData:(double) longitude: (double)latitude;
-(void)sendLocations;
@end
