//
//  BrowserViewController.m
//  HuskyPro
//
//  Created by LJJ on 13-7-23.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "BrowserViewController.h"
#import "DownloadViewController.h"
#import "MusicCell.h"

@interface BrowserViewController ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,UISearchDisplayDelegate>
@property (nonatomic, strong) DownloadViewController *downloadVC;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *musicDatasource;
@property (nonatomic, strong) UITableView *resultTable;
@end

@implementation BrowserViewController

- (id)init
{
    if (self = [super init]) {
        NSURL *url = [NSURL URLWithString:[@"http://music.baidu.com/search?key=你比从前快乐" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        _musicDatasource = [JJUtils parseHTMLToMusicTableByUrl:url];
        _downloadVC = [[DownloadViewController alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.frame = CGRectMake(0, 0, 320, 459);
    self.navigationItem.title = @"Musics";
    
    _resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _resultTable.delegate = self;
    _resultTable.dataSource = self;
    _resultTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [self.view addSubview:_resultTable];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    _searchBar.delegate = self;
//    [_resultTable.tableHeaderView addSubview:_address];
    [_resultTable.tableHeaderView addSubview:_searchBar];
}

- (void)viewDidLoad
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:[JJUtils fullPathInLibraryDirectory:@"musicCache"]]) {
        [manager createDirectoryAtPath:[JJUtils fullPathInLibraryDirectory:@"musicCache"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![manager fileExistsAtPath:[JJUtils fullPathInDocumentDirectory:@"music"]]) {
        [manager createDirectoryAtPath:[JJUtils fullPathInDocumentDirectory:@"music"] withIntermediateDirectories:NO attributes:nil error:nil];
    }

}

#pragma mark - my method


#pragma mark - SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSURL *url = [NSURL URLWithString:[[@"http://music.baidu.com/search?key=" stringByAppendingString:searchBar.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableArray *temp = [JJUtils parseHTMLToMusicTableByUrl:url];
    if (temp) {
        _musicDatasource = temp;
    }
    [_resultTable reloadData];
    [searchBar resignFirstResponder];
}


#pragma mark - UITableDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_musicDatasource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"historyCell";
     MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.singerLabel.text = [[[_musicDatasource objectAtIndex:indexPath.row] objectForKey:@"singer"] objectForKey:@"title"];
    cell.textLabel.text = [[[_musicDatasource objectAtIndex:indexPath.row] objectForKey:@"song"] objectForKey:@"title"];
    cell.detailTextLabel.text = [[[_musicDatasource objectAtIndex:indexPath.row] objectForKey:@"album"] objectForKey:@"title"];
    return cell;
}

#pragma mark - UITableDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:_downloadVC animated:YES];
    __weak NSDictionary *dict = [_musicDatasource objectAtIndex:indexPath.row];
    NSURL *url =[NSURL URLWithString:[@"http://music.baidu.com" stringByAppendingFormat:@"%@/download",[[dict objectForKey:@"song"] objectForKey:@"href"]]];
    [_downloadVC preapreDownloadVCWithUrl:url withInfo:dict];
}

@end
