//
//  JJUtils.m
//  HuskyPro
//
//  Created by LJJ on 13-7-25.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "JJUtils.h"
#import <string.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/tree.h>

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

#pragma mark - HTML Parser

+(NSArray *)parseHTMLToMusicTableByUrl:(NSURL *)url
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    
    NSString *query = @"/html/body/div[@class='music-main']/div/div/div[@class='main-body']/div/div[@class='search-result-container']/div[1]/ul/li/div";
    xmlDocPtr document = htmlReadMemory([data bytes], (int)[data length], "", nil, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    xmlXPathContextPtr xpathCtx = xmlXPathNewContext(document);
    xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    
    NSMutableArray *resultNodes = [NSMutableArray array];
    for (NSInteger i = 0; i < 1; i++)
    {
        NSDictionary *nodeDictionary = DictionaryFromNode(nodes->nodeTab[i], nil,false);
        if (nodeDictionary)
        {
            [resultNodes addObject:nodeDictionary];
        }
    }
    
    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    
    return resultNodes;
}

xmlNodePtr FindNodeByNodeNameAndAttribute(xmlNodePtr currentNode, const char *nodeName, const char *attributeName)
{
    while (currentNode) {
        if (currentNode && strcmp((const char *)currentNode->name, nodeName) == 0 ) {
            if (attributeName) {
                xmlAttr *attribute = currentNode->properties;
                while (attribute) {
                    if (strcmp((const char *)attribute->children->content, attributeName) == 0 ) {
                        return currentNode;
                    }
                    attribute = attribute->next;
                }
            } else {
                return currentNode;
            }
        }
        currentNode = currentNode->next;
    }
    NSLog(@"find nothing");
    return nil;
}

NSDictionary *DictionaryFromNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult,BOOL parentContent)
{
    NSMutableDictionary *songInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *singerInfo = [NSMutableDictionary dictionary];
    
    xmlNodePtr originNode = currentNode->children;
    
    xmlNodePtr childNode1 = FindNodeByNodeNameAndAttribute(originNode, "span", "song-title");
    childNode1 = childNode1->children;
    childNode1 = FindNodeByNodeNameAndAttribute(childNode1, "a", nil);
    xmlAttr *attribute1 = childNode1->properties;
    while (attribute1) {
        [songInfo setObject:[NSString stringWithCString:(const char *)attribute1->children->content encoding:NSUTF8StringEncoding]
                     forKey:[NSString stringWithCString:(const char *)attribute1->name encoding:NSUTF8StringEncoding]];
        attribute1 = attribute1->next;
    }
    
    xmlNodePtr childNode2 = FindNodeByNodeNameAndAttribute(originNode, "span", "singer");
    childNode2 = childNode2->children;
    childNode2 = FindNodeByNodeNameAndAttribute(childNode2, "span", "author_list");
    xmlAttr *attribute2 = childNode2->properties;
    while (attribute2) {
        [singerInfo setObject:[NSString stringWithCString:(const char *)attribute2->children->content encoding:NSUTF8StringEncoding]
                     forKey:[NSString stringWithCString:(const char *)attribute2->name encoding:NSUTF8StringEncoding]];
        attribute2 = attribute2->next;
    }
    
    xmlBufferPtr buffer = xmlBufferCreate();
    xmlNodeDump(buffer, currentNode->doc, currentNode, 0, 0);
    
//    NSString *rawContent = [NSString stringWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
//    [resultForNode setObject:rawContent forKey:@"raw"];
    
    xmlBufferFree(buffer);
    NSDictionary *resultForNode = [NSDictionary dictionaryWithObjectsAndKeys:songInfo, @"song", singerInfo, @"singer", nil];
    return resultForNode;
}




@end
