//
//  FileViewController.m
//  HuskyPro
//
//  Created by LJJ on 13-7-23.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "FileViewController.h"
#import "DownloadManager.h"

@interface FileViewController ()<UITableViewDataSource, UITableViewDelegate, DownloadManagerDelegate>
@property (nonatomic, strong) UITableView *downloadTable;
@property (nonatomic, strong) NSArray *tasks;
@end

@implementation FileViewController

- (id)init
{
    if (self = [super init]) {
        [DownloadManager sharedDownloadManager].delegate = self;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _downloadTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    _downloadTable.delegate = self;
    _downloadTable.dataSource = self;
    [self.view addSubview:_downloadTable];
}

- (void)viewWillAppear:(BOOL)animated
{
    _tasks = [[DownloadManager sharedDownloadManager] refreshDownloadTasks];
}

#pragma mark - downloadManagerDelegate
- (void)downloadManager:(DownloadManager *)manager taskNumberChangedWithInfo:(NSArray *)tasks
{
    _tasks = tasks;
    [_downloadTable reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tasks count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"downloadCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.text = [[_tasks objectAtIndex:indexPath.row] objectForKey:@"name"];
        UIProgressView *progress = [[_tasks objectAtIndex:indexPath.row] objectForKey:@"progress"];
        progress.frame = CGRectMake(100, 30, 200, 20);
        [cell addSubview:progress];
    }
    return cell;
}


@end








