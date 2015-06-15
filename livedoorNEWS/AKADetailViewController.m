//
//  AKADetailViewController.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/13.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKADetailViewController.h"
#import "AKARssWebViewController.h"
#import "AKAMarkAsArticle.h"

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
    
    [self setDateLabel];
    
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

- (void)setDateLabel {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    if ([[_article valueForKey:@"save"][_articleNumber] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        self.dateLabel.text = [NSString stringWithFormat:@"★ %@", [df stringFromDate:[_article valueForKey:@"date"][_articleNumber]]];
    } else {
        self.dateLabel.text = [df stringFromDate:[_article valueForKey:@"date"][_articleNumber]];
    }
}

- (IBAction)tapActionBtn:(id)sender {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:nil
                                                                 message:@"Change articles of state?"
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    UIAlertAction * readAction = [UIAlertAction actionWithTitle:@"Read"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              // 既読にする
                                                              AKAMarkAsArticle *mark = [[AKAMarkAsArticle alloc] init];
                                                              [mark changeUnread:[_article valueForKey:@"link"][_articleNumber]
                                                                          unread:[NSNumber numberWithBool:NO]];
                                                              
                                                              [_article[_articleNumber] setValue:[NSNumber numberWithDouble:NO]
                                                                                          forKey:@"unread"];
                                                          }];
    
    UIAlertAction * unreadAction = [UIAlertAction actionWithTitle:@"Unread"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              // 未読にする
                                                              AKAMarkAsArticle *mark = [[AKAMarkAsArticle alloc] init];
                                                              [mark changeUnread:[_article valueForKey:@"link"][_articleNumber]
                                                                          unread:[NSNumber numberWithBool:YES]];
                                                              
                                                              [_article[_articleNumber] setValue:[NSNumber numberWithDouble:YES]
                                                                                          forKey:@"unread"];
                                                          }];
    
    UIAlertAction * saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            // お気に入りにする
                                                            AKAMarkAsArticle *mark = [[AKAMarkAsArticle alloc] init];
                                                            [mark changeSave:[_article valueForKey:@"link"][_articleNumber]
                                                                        save:[NSNumber numberWithBool:YES]];
                                                            
                                                            [_article[_articleNumber] setValue:[NSNumber numberWithDouble:YES]
                                                                                        forKey:@"save"];
                                                            [self setDateLabel];
                                                        }];
    
    UIAlertAction * unsaveAction = [UIAlertAction actionWithTitle:@"Unsave"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            // お気に入りを解除する
                                                            AKAMarkAsArticle *mark = [[AKAMarkAsArticle alloc] init];
                                                            [mark changeSave:[_article valueForKey:@"link"][_articleNumber]
                                                                        save:[NSNumber numberWithBool:NO]];
                                                            
                                                            [_article[_articleNumber] setValue:[NSNumber numberWithDouble:NO]
                                                                                        forKey:@"save"];
                                                            [self setDateLabel];
                                                        }];
    
    [ac addAction:cancelAction];
    
    if ([[_article valueForKey:@"unread"][_articleNumber] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [ac addAction:readAction];
    } else {
        [ac addAction:unreadAction];
    }
    
    if ([[_article valueForKey:@"save"][_articleNumber] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [ac addAction:unsaveAction];
    } else {
        [ac addAction:saveAction];
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}
@end
