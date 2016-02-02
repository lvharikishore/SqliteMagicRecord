//
//  ViewController.m
//  SqliteMagicalRecord
//
//  Created by Hari Kishore on 02/02/16.
//  Copyright © 2016 Hari Kishore. All rights reserved.
//

#import "ViewController.h"
#import "/usr/include/sqlite3.h"

@interface ViewController () {
    NSString *databasePath;
    sqlite3 *contactDB;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"contacts.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)";
            
            if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
                NSLog(@"@@@@@Failed to create table");
            }
            
            sqlite3_close(contactDB);
            
        } else {
            //status.text = @"Failed to open/create database";
            NSLog(@"@@@@@Failed to open/create database");
        }
    }
    
    //[self saveData];
    [self findContact];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveData
{
    sqlite3_stmt    *statement;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        
        for (int i = 0; i < 10; i++) {
             NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO CONTACTS (name, address, phone) VALUES (\"%@\", \"%@\", \"%@\")", [NSString stringWithFormat:@"Name - %d",i], [NSString stringWithFormat:@"Address - %d",i], [NSString stringWithFormat:@"Phone - %d",i]];
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                 NSLog(@"@@@@@Contact added - %d", i);
                //status.text = @"Contact added";
                //name.text = @"";
                //address.text = @"";
                //phone.text = @"";
            } else {
                NSLog(@"@@@@@Failed to add contact");
            }
            sqlite3_finalize(statement);
        }
        
        
       
        sqlite3_close(contactDB);
    }
}

- (void) findContact
{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", @"Name - 3"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *addressField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                //address.text = addressField;
                NSLog(@"@@@ Address - %@",addressField);
                
                NSString *phoneField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                //phone.text = phoneField;
                NSLog(@"@@@ Phone - %@",phoneField);
                
                //status.text = @"Match found";
                NSLog(@"@@@ Match found");
                
            } else {
                NSLog(@"Match not found");
                //address.text = @"";
                //phone.text = @"";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
}

@end
