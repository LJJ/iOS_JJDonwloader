//
//  JJUtils.h
//  HuskyPro
//
//  Created by LJJ on 13-7-25.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JJUtils : NSObject
+ (NSString *)fullPathInDocumentDirectory:(NSString *)path;
+ (NSString *)fullPathInLibraryDirectory:(NSString *)path;
+(BOOL) shouldDownloadTheUrl:(NSURL *)url;
+(NSString*) getCutedPathWithPath:(NSString *)path;
+(NSArray *)parseHTMLToMusicTableByUrl:(NSURL *)url;
@end
