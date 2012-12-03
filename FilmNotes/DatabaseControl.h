//
//  DatabaseControl.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/2/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseControl : NSObject
@property (strong, nonatomic) NSMutableArray *filmArray;
@property (strong, nonatomic) NSMutableArray *entries;
@property (nonatomic) sqlite3 *FilmNotesDB;
-(NSString *)filePath;
-(void)openDB;
-(NSMutableArray *)readTable:(NSString*)sql;
-(void)createTable;
-(void) sendSqlData:(NSString *)sql whichTable:(NSString *)table;
-(NSString *)singleRead:(NSString *)sql;
-(void)removeRoll:(NSString *)rollId;
@end
