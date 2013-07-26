//
//  BrowserViewController.m
//  HuskyPro
//
//  Created by LJJ on 13-7-23.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()<UISearchBarDelegate, UIWebViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,UISearchDisplayDelegate>
@property (nonatomic, strong) UIWebView *browser;
@property (nonatomic, strong) UITextField *address;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *historyData;
@end

@implementation BrowserViewController

- (void)loadView
{
    [super loadView];
    _browser = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _browser.delegate = self;
    [self.view addSubview:_browser];
    _address = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
    _address.borderStyle = UITextBorderStyleRoundedRect;
    _address.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _address.returnKeyType = UIReturnKeyGo;
    _address.clearButtonMode = UITextFieldViewModeWhileEditing;
    _address.delegate = self;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(220, 0, 100, 40)];
    _searchBar.delegate = self;
    [self.view addSubview:_address];
    [self.view addSubview:_searchBar];
    
    _historyData = [[NSMutableArray alloc] initWithObjects:@"1", nil];

    
}

- (void)viewDidLoad
{
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [_browser loadRequest:req];
}

#pragma mark - SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSURL *url = [NSURL URLWithString:[[@"http://music.baidu.com/search?key=" stringByAppendingString:searchBar.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_browser loadRequest:req];
    [searchBar resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[@"http://" stringByAppendingString:textField.text]]];
    [_browser loadRequest:req];
    return YES;
}



//#pragma mark - UITableDatasource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [_historyData count];
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *identifier = @"historyCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.textLabel.text = [_historyData objectAtIndex:indexPath.row];
//    }
//    return cell;
//}

//#pragma mark - UITableDelegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    _searchBar.text = [_historyData objectAtIndex:indexPath.row];
//}

#pragma mark - UIWebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([JJUtils shouldDownloadTheUrl:request.URL]) {
        UIViewController *preVC = [[UIViewController alloc] init];
        preVC.view.backgroundColor = [UIColor yellowColor];
        [self presentViewController:preVC animated:YES completion:^{
            
        }];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"1");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}

@end
