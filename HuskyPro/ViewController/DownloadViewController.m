//
//  DownloadViewController.m
//  HuskyPro
//
//  Created by LJJ on 13-7-30.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadManager.h"

@interface DownloadViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *browser;
@property (nonatomic, weak) NSString *name;
@property (nonatomic, weak) NSString *author;
@property (nonatomic, weak) NSString *album;
@end

@implementation DownloadViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = @"Download";
    _browser = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _browser.delegate = self;
    [self.view addSubview:_browser];
}

- (void)preapreDownloadVCWithUrl:(NSURL *)url withInfo:(NSDictionary *)info
{
    _name = [[info objectForKey:@"song"] objectForKey:@"title"];
    _author = [[info objectForKey:@"singer"] objectForKey:@"title"];
    _album = [[info objectForKey:@"album"] objectForKey:@"title"];
    
    [_browser loadRequest:[NSURLRequest requestWithURL:url]];
    url = nil;
}


#pragma mark - UIWebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([JJUtils shouldDownloadTheUrl:request.URL]) {
        [[DownloadManager sharedDownloadManager] downloadMusicByURL:request.URL withName:_name andAuthor:_author];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}

@end
