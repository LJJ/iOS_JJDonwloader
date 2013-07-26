//
//  JJUtils.m
//  HuskyPro
//
//  Created by LJJ on 13-7-25.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "JJUtils.h"
#define PRINTOBJECT(args...) 

@implementation JJUtils

+ (NSString *)fullPathInDocumentDirectory:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:path];
}

+ (NSString *)fullPathInLibraryDirectory:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libDirectory = [paths objectAtIndex:0];
    return [libDirectory stringByAppendingPathComponent:path];
}

+(NSString*)getURLPathFileFormant:(NSString*)path
{//some thing like /xxxx.xxxx?xxxxx
	//cut "/"
	NSString* cutPath = [JJUtils getCutedPathWithPath:path];
	NSRange range = [cutPath rangeOfString:@"."];
	while (range.location != NSNotFound && (range.location<[cutPath length]-1))
	{
		cutPath = [cutPath substringFromIndex:range.location+1];
		range = [cutPath rangeOfString:@"."];
	}
	return cutPath;
}

+(BOOL)isFileTypeKnown:(NSString *)fileType
{
	NSArray* array = [NSArray arrayWithObjects:@"mp3",@"xlsx",@"xls",@"docx",@"doc",@"wma",@"zip",@"wav",@"txt"
					  ,@"rtf",@"rar",@"pptx",@"ppt",@"pdf",@"mp4",@"jpg", @"png",@"bmp",@"mov",@"gif",@"jif",@"ico",@"mpg",nil];
	if ([array containsObject:[fileType lowercaseString]])
	{
		return YES;
	}
	return NO;
}

+(BOOL) shouldDownloadTheUrl:(NSURL *)url
{
	PRINTOBJECT(@"The url path is %@", [url absoluteString]);
	NSString* path = [url absoluteString];
	if ([path length] < 3)
	{
		return NO;
	}
	return [JJUtils isFileTypeKnown:[JJUtils getURLPathFileFormant:path]];
}

+(NSString*) getCutedPathWithPath:(NSString *)path
{// must make sure the path is more than 3 chars
	NSString* cutPath = path;
	while (TRUE)
	{
		NSRange range = [cutPath rangeOfString:@"/"];
		if (range.location != NSNotFound)
		{
			cutPath = [cutPath substringFromIndex:range.location+1];
		}
		else
		{
			range = [cutPath rangeOfString:@"?"];
			if (range.location != NSNotFound && range.location != 0)
			{
				cutPath = [cutPath substringToIndex:range.location];
			}
			PRINTOBJECT(@"fileName with path : %@", cutPath);
			return cutPath;
		}
        
	}
}


@end
