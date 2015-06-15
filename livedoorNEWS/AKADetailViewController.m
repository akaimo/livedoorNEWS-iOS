//
//  AKADetailViewController.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/13.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKADetailViewController.h"
#import "AKARssWebViewController.h"

@interface AKADetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *relation1Label;
@property (weak, nonatomic) IBOutlet UILabel *relation2Label;
@property (weak, nonatomic) IBOutlet UILabel *relation3Label;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
- (IBAction)tapActionBtn:(id)sender;

@property (strong, nonatomic) NSMutableArray *relationNumber;

@end

@implementation AKADetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 次のViewの戻るボタンの設定
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    self.title = [[_article valueForKey:@"category"] valueForKey:@"name"][_articleNumber];
    self.titleLabel.text = [_article valueForKey:@"title"][_articleNumber];
    self.titleLabel.userInteractionEnabled = YES;
    self.titleLabel.tag = 100;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    self.dateLabel.text = [df stringFromDate:[_article valueForKey:@"date"][_articleNumber]];
    
    NSError *err = nil;
    self.detailLabel.attributedText = [[NSAttributedString alloc]
                                       initWithData:[[_article valueForKey:@"detail"][_articleNumber] dataUsingEncoding:NSUTF8StringEncoding]
                                       options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                                                 NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                       documentAttributes:nil error:&err];
    if(err) NSLog(@"Unable to parse label text: %@", err);
    self.detailLabel.font = [UIFont fontWithName:@"System" size:15];
    self.detailLabel.userInteractionEnabled = YES;
    self.detailLabel.tag = 101;
    
    _relationNumber = [NSMutableArray arrayWithArray:[self getRelationNumber]];
    self.relation1Label.text = [_article valueForKey:@"title"][[_relationNumber[0] intValue]];
    self.relation1Label.userInteractionEnabled = YES;
    self.relation1Label.tag = 200;
    
    self.relation2Label.text = [_article valueForKey:@"title"][[_relationNumber[1] intValue]];
    self.relation2Label.userInteractionEnabled = YES;
    self.relation2Label.tag = 201;
    
    self.relation3Label.text = [_article valueForKey:@"title"][[_relationNumber[2] intValue]];
    self.relation3Label.userInteractionEnabled = YES;
    self.relation3Label.tag = 202;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    AKARssWebViewController *vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"RssWebViewController"];
    switch (touch.view.tag) {
        case 100:
            vc.url = [_article valueForKey:@"link"][_articleNumber];
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        case 101:
            vc.url = [_article valueForKey:@"link"][_articleNumber];
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        case 200:
            vc.url = [_article valueForKey:@"link"][[_relationNumber[0] intValue]];
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        case 201:
            vc.url = [_article valueForKey:@"link"][[_relationNumber[1] intValue]];
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        case 202:
            vc.url = [_article valueForKey:@"link"][[_relationNumber[2] intValue]];
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        default:
            break;
    }
}

- (NSArray *)getRelationNumber {
    // TODO: 同一の数や現在表示中とかぶったときの処理
    // TODO: カテゴリー内の記事が3個未満のときの対応
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        int count = (int)_article.count;
        int num = (int)arc4random_uniform(count);
        [array addObject:[NSNumber numberWithInteger:num]];
    }
    return  array;
}

- (IBAction)tapActionBtn:(id)sender {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:nil
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              // ボタンタップ時の処理
                                                          }];
    
    UIAlertAction * unreadAction = [UIAlertAction actionWithTitle:@"Unread"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              // ボタンタップ時の処理
                                                          }];
    
    UIAlertAction * saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            // ボタンタップ時の処理
                                                        }];
    
    [ac addAction:cancelAction];
    [ac addAction:unreadAction];
    [ac addAction:saveAction];
    
    [self presentViewController:ac animated:YES completion:nil];
}
@end
