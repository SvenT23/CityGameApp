//
//  SqliteDb.m
//  MapkitAppCitygame
//
//  Created by Wim on 29/01/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import "SqliteDb.h"
#import "Coordinate.h"
@implementation SqliteDb

-(void)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent:
                                     @"playerLocations.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS LOCATIONS (ID INTEGER PRIMARY KEY AUTOINCREMENT, Longitude DOUBLE, Latitude DOUBLE)";
            
            if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }else{
                 NSLog(@"Tabel aangemaakt");
            }
            sqlite3_close(db);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

-(void)saveData:(double) longitude: (double)latitude{
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO LOCATIONS (Longitude, Latitude) VALUES (\"%f\", \"%f\")",longitude, latitude];

        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
          {
              NSLog(@"location added");
          } else {
              NSLog(@"Failed to add location");
          }
              sqlite3_finalize(statement);
              sqlite3_close(db);
          }
}

-(void)sendLocations{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    //NSMutableDictionary *coordinates = [[NSMutableDictionary alloc]init];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM LOCATIONS ORDER BY ID"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(db,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //NSNumber *id = [NSNumber numberWithInt:(int)sqlite3_column_double(statement, 1)];
                NSNumber *longitude = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 1)];
                
                NSNumber *latitude = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 2)];
                Coordinate *newCoordinate = [[Coordinate alloc] init];
                newCoordinate.latitude = latitude;
                newCoordinate.longitude = longitude;

                //[coordinates setObject:id forKey:newCoordinate];
                
                NSLog(@"%@,%@",newCoordinate.latitude, newCoordinate.longitude);
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
}

@end
