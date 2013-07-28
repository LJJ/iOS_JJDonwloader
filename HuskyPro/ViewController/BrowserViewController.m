//
//  BrowserViewController.m
//  HuskyPro
//
//  Created by LJJ on 13-7-23.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "BrowserViewController.h"
#import "DownloadManager.h"
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>

@interface BrowserViewController ()<UISearchBarDelegate, UIWebViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,UISearchDisplayDelegate>
@property (nonatomic, strong) UIWebView *browser;
@property (nonatomic, strong) UITextField *address;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *historyData;
@property (nonatomic, strong) UITableView *resultTable;
@end

@implementation BrowserViewController

- (id)init
{
    if (self = [super init]) {
        NSURL *url = [NSURL URLWithString:[@"http://music.baidu.com/search?key=那些年" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        
        NSString *query = @"/html/body/div[@class='music-main']/div/div/div[@class='main-body']/div/div[@class='search-result-container']/div[1]/ul/li/div/span[@class='song-title']/a/em/em/text()";
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
        
        NSLog(@"node %@",[resultNodes objectAtIndex:0]);
        
    }
    return self;
}

NSDictionary *DictionaryFromNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult,BOOL parentContent)
{
    NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
    
    if (currentNode->name)
    {
        NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
        NSLog(@"name %@",currentNodeContent);
        [resultForNode setObject:currentNodeContent forKey:@"nodeName"];

    }
    
    if (currentNode->content && currentNode->content != (xmlChar *)-1)
    {
        NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];
        NSLog(@"content %@",currentNodeContent);
        
        if ([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult)
        {
            if(parentContent)
            {
                [parentResult setObject:[currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"nodeContent"];
                return nil;
            }
            [resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
            //            NSLog(@"content: %@",currentNodeContent);
            return resultForNode;
            
        }
        else {
            [resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
        }
        
        
    }
    
    xmlAttr *attribute = currentNode->properties;
    if (attribute)
    {
        NSMutableArray *attributeArray = [NSMutableArray array];
        while (attribute)
        {
            NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
            NSString *attributeName =
            [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
            if (attributeName)
            {
                //                NSLog(@"Attribute Name Set: %@",attributeName);
                [attributeDictionary setObject:attributeName forKey:@"attributeName"];
            }
            
            if (attribute->children)
            {
                NSDictionary *childDictionary = DictionaryFromNode(attribute->children, attributeDictionary,true);
                if (childDictionary)
                {
                    [attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
                }
            }
            
            if ([attributeDictionary count] > 0)
            {
                [attributeArray addObject:attributeDictionary];
            }
            attribute = attribute->next;
        }
        
        if ([attributeArray count] > 0)
        {
            [resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
        }
    }
    
    xmlNodePtr childNode = currentNode->children;
    if (childNode)
    {
        NSMutableArray *childContentArray = [NSMutableArray array];
        while (childNode)
        {
            NSDictionary *childDictionary = DictionaryFromNode(childNode, resultForNode,false);
            if (childDictionary)
            {
                [childContentArray addObject:childDictionary];
            }
            childNode = childNode->next;
        }
        if ([childContentArray count] > 0)
        {
            [resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
        }
    }
    
    xmlBufferPtr buffer = xmlBufferCreate();
    xmlNodeDump(buffer, currentNode->doc, currentNode, 0, 0);
    
    NSString *rawContent = [NSString stringWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
    [resultForNode setObject:rawContent forKey:@"raw"];
    
    xmlBufferFree(buffer);
    
    return resultForNode;
}


- (void)loadView
{
    [super loadView];
    _browser = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _browser.delegate = self;
//    [self.view addSubview:_browser];
    
    _resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    _resultTable.delegate = self;
//    _resultTable.dataSource = self;
    [self.view addSubview:_resultTable];
    
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
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://music.baidu.com"]];
    [_browser loadRequest:req];

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



#pragma mark - UITableDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_historyData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"historyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.text = [_historyData objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - UITableDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _searchBar.text = [_historyData objectAtIndex:indexPath.row];
}

#pragma mark - UIWebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([JJUtils shouldDownloadTheUrl:request.URL]) {
        [[DownloadManager sharedDownloadManager] downloadMusicByURL:request.URL];
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
