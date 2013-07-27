//
//  DownloadManager.h
//  HuskyPro
//
//  Created by LJJ on 13-7-26.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "ASIHTTPRequest.h"
@class DownloadManager;

@protocol DownloadManagerDelegate <NSObject>
@optional
- (void)downloadManager:(DownloadManager *)manager taskNumberChangedWithInfo:(NSArray *)tasks;
- (void)suspendOneTaskAtIndex:(NSInteger)index;
- (void)recoverOneTaskAtIndex:(NSInteger)index withAllInfo:(NSDictionary *)userInfo;

@end

@interface DownloadManager : NSObject
SYNTHESIZE_SINGLETON_FOR_HEADER(DownloadManager)
@property (weak) id<DownloadManagerDelegate> delegate;

- (void)downloadMusicByURL:(NSURL *)url;
- (NSArray *)refreshDownloadTasks;

- (void)suspendOrRevoverDownload:(ASIHTTPRequest *)request;

@end
