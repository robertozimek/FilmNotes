//
//  DatabaseControl.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/2/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "DatabaseControl.h"

#define FIELDS 8

@implementation DatabaseControl
@synthesize FilmNotesDB = _FilmNotesDB;

-(NSString *)filePath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[path objectAtIndex:0] stringByAppendingPathComponent:@"FilmNotes.db"];
}

-(void)openDB{
    if (sqlite3_open([[self filePath] UTF8String], &_FilmNotesDB) != SQLITE_OK){
        sqlite3_close(_FilmNotesDB);
        NSAssert(0,@"Database failed to open");
    }else
    {
        char *err;
        NSString *sql = [NSString stringWithFormat:@"PRAGMA foreign_keys = ON"];
        if (sqlite3_exec(_FilmNotesDB,[sql UTF8String],NULL,NULL,&err) != SQLITE_OK) {
            NSLog(@"PRAGMA foreign_keys = ON Failed.");
        }
    }
}

-(void)createTable
{
    [self openDB];
    char *err;
    NSString *sql = @"CREATE TABLE IF NOT EXISTS Roll (id INTEGER PRIMARY KEY AUTOINCREMENT,Exposures INTEGER,FilmName TEXT,Iso INTEGER,Camera TEXT,Date TEXT);CREATE TABLE IF NOT EXISTS Exposure (Exposure INTEGER NOT NULL,Roll_id INTEGER,Focal INTEGER,Aperture DOUBLE,Shutter TEXT,Gps TEXT, Notes TEXT,FOREIGN KEY (Roll_id) REFERENCES Roll(id) ON DELETE CASCADE);CREATE TABLE IF NOT EXISTS Defaults (id INTEGER PRIMARY KEY AUTOINCREMENT,FilmName TEXT,Iso INTEGER,Exposure INTEGER,Camera TEXT,Focal INTEGER,Aperture DOUBLE,Gps TEXT);";
    if(sqlite3_exec(_FilmNotesDB, [sql UTF8String], NULL,NULL,&err) != SQLITE_OK)
    {
        sqlite3_close(_FilmNotesDB);
        NSAssert(0,@"Could not create table");
    }else{
        NSLog(@"table_create");
    }
    sqlite3_close(_FilmNotesDB);
}

-(void) sendSqlData:(NSString *)sql whichTable:(NSString *)table
{
    [self openDB];
    char *err;
    if(sqlite3_exec(_FilmNotesDB,[sql UTF8String],NULL,NULL,&err) !=SQLITE_OK)
    {
        NSLog(@"%@ 444", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(_FilmNotesDB)]);
        NSAssert(0,@"Could not update %@ table",table);
    }else{
        NSLog(@"%@ table updated",table);
    }
    sqlite3_close(_FilmNotesDB);
}

-(NSMutableArray *)readTable:(NSString *)sql
{
    [self openDB];
    NSMutableArray *filmArray = [[NSMutableArray alloc] init];
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare(_FilmNotesDB, [sql UTF8String],-1,&statement,nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement)==SQLITE_ROW)
        {
            for(int i = 0; i < FIELDS; i++) {
                NSString *fieldStr = @"";
                char *field = (char *) sqlite3_column_text(statement,i);
                if(field != NULL)
                    fieldStr = [[NSString alloc]initWithUTF8String:field];
                [entries addObject:fieldStr];
            }
 
            //NSLog(@"[entries mutableCopy] %@",[entries mutableCopy]);
            
            [filmArray addObject:[entries mutableCopy]];
            [entries removeAllObjects];
        }
    }
    else
        NSLog(@"ERROR: %@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(_FilmNotesDB)]);
    sqlite3_finalize(statement);
    sqlite3_close(_FilmNotesDB);
    
    return filmArray;
}

-(NSString *)singleRead:(NSString *)sql
{
    [self openDB];
    NSString *str = @"";
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare(_FilmNotesDB, [sql UTF8String],-1,&statement,nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement)==SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc]initWithUTF8String:field1];
            str = [[NSString alloc] initWithFormat:@"%@",field1Str];
        }
    }
    else
        NSLog(@"ERROR: %@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(_FilmNotesDB)]);
    sqlite3_finalize(statement);
    sqlite3_close(_FilmNotesDB);

    return str;
}

-(void)removeRow:(NSString *)defaultID inTable:(NSString *)table
{
    [self openDB];
    
    NSString *sql = [NSString stringWithFormat:@"delete from '%@' where id=%@",table,defaultID];
    char *err;
    if(sqlite3_exec(_FilmNotesDB,[sql UTF8String],NULL,NULL,&err) != SQLITE_OK)
    {
        NSAssert(0,@"Unable to remove row at id=%@ in table '%@",defaultID,table);
    }
    sqlite3_close(_FilmNotesDB);
}

@end
