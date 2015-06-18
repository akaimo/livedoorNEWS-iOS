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

@property (strong, nonatomic) UIBarButtonItem *actionBtn;
@property (strong, nonatomic) UIBarButtonItem *refreshBtn;
@property (strong, nonatomic) UIBarButtonItem *stopBtn;
@property (strong, nonatomic) UIBarButtonItem *forwardBtn;
@property (strong, nonatomic) UIBarButtonItem *backBtn;

@property (nonatomic) int webViewLoads;

@end

@implementation AKARssWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:_url];
    [_rssWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    _actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                               target:self
                                                               action:@selector(actionBtnTap:)];
    _refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                target:self
                                                                action:@selector(refreshBtnTap:)];
    _stopBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                             target:self
                                                             action:@selector(stopBtnTap:)];
    _forwardBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nextWebBtn"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(forwardBtnTap:)];
    _backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWebBtn"]
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(backBtnTap:)];
    self.navigationItem.rightBarButtonItems = @[_actionBtn, _refreshBtn, _forwardBtn, _backBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.rssWebView.isLoading) {
        [self.rssWebView stopLoading];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    /* 戻る・進むボタンのタップ可否を制御 */
    self.backBtn.enabled = self.rssWebView.canGoBack;
    self.forwardBtn.enabled = self.rssWebView.canGoForward;
    
    /* navigationbarのitemを入れ替える */
    NSMutableArray *changedBarButtonItemArray = [NSMutableArray arrayWithArray:[self.navigationItem rightBarButtonItems]];
    [changedBarButtonItemArray replaceObjectAtIndex:1 withObject:_stopBtn];
    self.navigationItem.rightBarButtonItems = changedBarButtonItemArray;
    
    _webViewLoads++;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webViewLoads--;
    
    if (_webViewLoads <= 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSMutableArray *changedBarButtonItemArray = [NSMutableArray arrayWithArray:[self.navigationItem rightBarButtonItems]];
        [changedBarButtonItemArray replaceObjectAtIndex:1 withObject:_refreshBtn];
        self.navigationItem.rightBarButtonItems = changedBarButtonItemArray;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _webViewLoads--;
    NSLog(@"error webView");
}

- (void)refreshBtnTap:(UIButton *)sender {
    [self.rssWebView reload];
}

- (void)stopBtnTap:(UIButton *)sender {
    [self.rssWebView stopLoading];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSMutableArray *changedBarButtonItemArray = [NSMutableArray arrayWithArray:[self.navigationItem rightBarButtonItems]];
    [changedBarButtonItemArray replaceObjectAtIndex:1 withObject:_refreshBtn];
    self.navigationItem.rightBarButtonItems = changedBarButtonItemArray;
}

- (void)forwardBtnTap:(UIButton *)sender {
    if (self.rssWebView.canGoForward) [self.rssWebView goForward];
}

- (void)backBtnTap:(UIButton *)sender {
    if (self.rssWebView.canGoBack) [self.rssWebView goBack];
}

- (void)actionBtnTap:(UIButton *)sender {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:nil
                                                                 message:@"share"
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    UIAlertAction * safariAction = [UIAlertAction actionWithTitle:@"Open in Safari"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSURL *url = [NSURL URLWithString:_url];
                                                              [[UIApplication sharedApplication] openURL:url];
                                                          }];
    
    [ac addAction:cancelAction];
    [ac addAction:safariAction];
    
    [self presentViewController:ac animated:YES completion:nil];
}

@end
