//
//  DatabaseControl.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/2/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "DatabaseControl.h"

@implementation DatabaseControl
@synthesize FilmNotesDB = _FilmNotesDB;
@synthesize filmArray;
@synthesize entries;

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
    NSString *sql = @"CREATE TABLE IF NOT EXISTS Roll (id INTEGER PRIMARY KEY AUTOINCREMENT,ExposureId INTEGER,FilmName TEXT,Iso INTEGER,Camera TEXT,Date TEXT);CREATE TABLE IF NOT EXISTS Exposure (id INTEGER NOT NULL,Roll_id INTEGER,Exposure_Id INTEGER,Focal INTEGER,Aperture DOUBLE,Shutter TEXT,Gps TEXT, Notes TEXT,FOREIGN KEY (Roll_id) REFERENCES Roll(id) ON DELETE CASCADE);CREATE TABLE IF NOT EXISTS Defaults (id INTEGER PRIMARY KEY AUTOINCREMENT,FilmName TEXT,Iso INTEGER,Exposure INTEGER,Camera TEXT,Focal INTEGER,Aperture DOUBLE,Gps TEXT);";
    if(sqlite3_exec(_FilmNotesDB, [sql UTF8String], NULL,NULL,&err) != SQLITE_OK)
    {
        sqlite3_close(_FilmNotesDB);
        NSAssert(0,@"Could not create table");
    }else{
        NSLog(@"table_create");
    }
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
}

-(NSMutableArray *)readTable:(NSString *)sql
{
    [self openDB];
    filmArray = [[NSMutableArray alloc] init];
    entries = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare(_FilmNotesDB, [sql UTF8String],-1,&statement,nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement)==SQLITE_ROW)
        {
            NSString *field1Str = @"";
            NSString *field2Str = @"";
            NSString *field3Str = @"";
            NSString *field4Str = @"";
            NSString *field5Str = @"";
            NSString *field6Str = @"";
            NSString *field7Str = @"";
            NSString *field8Str = @"";
            
            
            char *field1 = (char *) sqlite3_column_text(statement,0);
            if (field1 != NULL)
                field1Str = [[NSString alloc]initWithUTF8String:field1];
            [entries addObject:field1Str];
                
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            if (field2 != NULL)
                field2Str = [[NSString alloc]initWithUTF8String:field2];
            [entries addObject:field2Str];
            
            
            char *field3 = (char *) sqlite3_column_text(statement,2);
            if (field3 != NULL)
                field3Str = [[NSString alloc]initWithUTF8String:field3];
            [entries addObject:field3Str];
            
            
            char *field4 = (char *) sqlite3_column_text(statement,3);
            if (field4 != NULL)
                field4Str = [[NSString alloc]initWithUTF8String:field4];
            [entries addObject:field4Str];
            
            
            char *field5 = (char *) sqlite3_column_text(statement,4);
            if (field5 != NULL)
                field5Str = [[NSString alloc]initWithUTF8String:field5];
            [entries addObject:field5Str];
            
            
            char *field6 = (char *) sqlite3_column_text(statement,5);
            if (field6 != NULL)
                field6Str = [[NSString alloc]initWithUTF8String:field6];
            [entries addObject:field6Str];
            
            
            char *field7 = (char *) sqlite3_column_text(statement,6);
            if (field7 != NULL)
                field7Str = [[NSString alloc]initWithUTF8String:field7];
            [entries addObject:field7Str];
            
            char *field8 = (char *) sqlite3_column_text(statement,7);
            if (field8 != NULL)
                field8Str = [[NSString alloc]initWithUTF8String:field8];
            [entries addObject:field8Str];
            
 
            [filmArray addObject:[entries copy]];
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
    filmArray = [[NSMutableArray alloc] init];
    entries = [[NSMutableArray alloc] init];
    
    //NSString *sql = [NSString stringWithFormat:@"SELECT MAX(ID) FROM Roll"];
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
}

@end
