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

- (void)downloadMusicByURL:(NSURL *)url
{
        
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
    }
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [self configRequest:req];

    [_downloadQueue addOperation:req];
}

- (void)configRequest:(ASIHTTPRequest *)req
{
    NSString *filePath = [JJUtils getCutedPathWithPath:req.url.absoluteString];
    NSArray *components = [filePath componentsSeparatedByString:@"."];
    NSString *fileType = [components objectAtIndex:1];
    NSString *fileName = [components objectAtIndex:0];
    
    req.delegate = self;
    req.allowResumeForFileDownloads = YES;
    UIProgressView *myprogress = [[UIProgressView alloc] init];
    myprogress.frame = CGRectMake(100, 30, 200, 20);
    req.downloadProgressDelegate = myprogress;
    req.temporaryFileDownloadPath = [JJUtils fullPathInLibraryDirectory:[NSString stringWithFormat:@"musicCache/%@.download",fileName]];
    req.downloadDestinationPath = [JJUtils fullPathInDocumentDirectory:[NSString stringWithFormat:@"music/%@.%@",fileName,fileType]];
    
    __weak ASIHTTPRequest *request = req;
    req.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:myprogress, @"progress", fileName, @"name", request, @"request", req.url,@"url", nil];
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
        [self configRequest:req];
        [_tasks replaceObjectAtIndex:row withObject:req.userInfo];
        if ([_delegate respondsToSelector:@selector(recoverOneTaskAtIndex:withAllInfo:)]) {
            [_delegate recoverOneTaskAtIndex:row withAllInfo:req.userInfo];
        }
        [_downloadQueue addOperation:req];
    }
    
}

#pragma mark - asihttprequest delegate

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    if ([_delegate respondsToSelector:@selector(downloadManager:taskNumberChangedWithInfo:)] && [_tasks indexOfObject:request.userInfo] == NSNotFound) {
        [_tasks addObject:request.userInfo];
        [_delegate downloadManager:self taskNumberChangedWithInfo:_tasks];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if ([_delegate respondsToSelector:@selector(downloadManager:taskNumberChangedWithInfo:)] && [_tasks indexOfObject:request.userInfo] != NSNotFound) {
        [_tasks removeObject:request.userInfo];
        [_delegate downloadManager:self taskNumberChangedWithInfo:_tasks];
    }
}

@end
