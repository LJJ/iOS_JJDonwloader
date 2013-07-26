//
//  DataCenter.m
//  HuskyPro
//
//  Created by LJJ on 13-7-25.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "DataCenter.h"
#import "FMDatabase.h"

@implementation DataCenter
SYNTHESIZE_SINGLETON_FOR_CLASS(DataCenter)

- (id)init
{
    if (self = [super init]) {
        NSString *path = [JJUtils fullPathInLibraryDirectory:@"HuskyPro.db"];
        FMDatabase *db = [FMDatabase databaseWithPath:path];
        if (![db open]) {
            NSLog(@"cannot open db");
        }
    }
    return self;
}

@end
