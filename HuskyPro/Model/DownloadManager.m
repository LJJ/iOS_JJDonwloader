//
//  DownloadManager.m
//  HuskyPro
//
//  Created by LJJ on 13-7-26.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "DownloadManager.h"


@interface DownloadManager ()<ASIHTTPRequestDelegate>
@property (strong) NSOperationQueue *downloadQueue;
@property (strong) NSMutableArray *tasks;

@end

@implementation DownloadManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DownloadManager)

- (id)init
{
    if (self = [super init]) {
        _tasks = [[NSMutableArray alloc] initWithCapacity:40];
    }
    return self;
}

- (NSArray *)refreshDownloadTasks
{
    return _tasks;
}

- (void)downloadMusicByURL:(NSURL *)url withName:(NSString *)name andAuthor:(NSString *)artist
{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
    }
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    
    NSString *filePath = [JJUtils getCutedPathWithPath:req.url.absoluteString];
    NSArray *components = [filePath componentsSeparatedByString:@"."];
    NSString *fileType = [components objectAtIndex:1];
    
    UIProgressView *myprogress = [[UIProgressView alloc] init];
    __weak ASIHTTPRequest *request = req;
    req.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:myprogress, @"progress", name, @"name", fileType, @"type", artist, @"arthor", request, @"request", req.url,@"url", nil];
    [self configRequest:req];
    
    if ([_delegate respondsToSelector:@selector(downloadManager:taskNumberChangedWithInfo:)] && [_tasks indexOfObject:request.userInfo] == NSNotFound) {
        [_tasks addObject:request.userInfo];
        [_delegate downloadManager:self taskNumberChangedWithInfo:_tasks];
    }

    [_downloadQueue addOperation:req];
    req = nil;
}

- (void)configRequest:(ASIHTTPRequest *)req
{
    req.delegate = self;
    req.allowResumeForFileDownloads = YES;
    __weak UIProgressView *myProgress = [req.userInfo objectForKey:@"progress"];
    myProgress.frame = CGRectMake(100, 30, 200, 20);
    req.downloadProgressDelegate = myProgress;
    req.temporaryFileDownloadPath = [JJUtils fullPathInLibraryDirectory:[NSString stringWithFormat:@"musicCache/%@.download",[req.userInfo objectForKey:@"name"]]];
    req.downloadDestinationPath = [JJUtils fullPathInDocumentDirectory:[NSString stringWithFormat:@"music/%@.%@",[req.userInfo objectForKey:@"name"],[req.userInfo objectForKey:@"type"]]];
}

- (void)suspendOrRevoverDownload:(ASIHTTPRequest *)request
{
    NSInteger row = [_tasks indexOfObject:request.userInfo];
    if (![request isCancelled]) {
        [request clearDelegatesAndCancel];
        if ([_delegate respondsToSelector:@selector(suspendOneTaskAtIndex:)]) {
            [_delegate suspendOneTaskAtIndex:row];
        }
        
    }
    else {
        ASIHTTPRequest *req = [[ASIHTTPRequest alloc] initWithURL:[request.userInfo objectForKey:@"url"]];
        req.userInfo = request.userInfo;
        [self configRequest:req];
        [_downloadQueue addOperation:req];
        request = nil;
    }
    
}

#pragma mark - asihttprequest delegate

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if ([_delegate respondsToSelector:@selector(downloadManager:taskNumberChangedWithInfo:)] && [_tasks indexOfObject:request.userInfo] != NSNotFound) {
        [_tasks removeObject:request.userInfo];
        [_delegate downloadManager:self taskNumberChangedWithInfo:_tasks];
    }
}

@end
