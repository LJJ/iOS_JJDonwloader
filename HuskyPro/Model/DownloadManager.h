//
//  DownloadManager.h
//  HuskyPro
//
//  Created by LJJ on 13-7-26.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
@class DownloadManager;

@protocol DownloadManagerDelegate <NSObject>
@optional
- (void)downloadManager:(DownloadManager *)manager taskNumberChangedWithInfo:(NSArray *)tasks;

@end

@interface DownloadManager : NSObject
SYNTHESIZE_SINGLETON_FOR_HEADER(DownloadManager)
@property (assign) id<DownloadManagerDelegate> delegate;

- (void)downloadMusicByURL:(NSURL *)url;
- (NSArray *)refreshDownloadTasks;

@end
