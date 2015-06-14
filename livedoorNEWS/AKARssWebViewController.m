//
//  AKARssWebViewController.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/13.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKARssWebViewController.h"

@interface AKARssWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *rssWebView;

@end

@implementation AKARssWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:_url];
    NSLog(@"%@", _url);
    [_rssWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

@end
