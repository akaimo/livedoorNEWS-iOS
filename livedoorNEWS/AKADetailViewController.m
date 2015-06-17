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
#import "AKAFetchData.h"

@interface AKADetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *relation1Label;
@property (weak, nonatomic) IBOutlet UILabel *relation2Label;
@property (weak, nonatomic) IBOutlet UILabel *relation3Label;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
- (IBAction)tapActionBtn:(id)sender;

@property (strong, nonatomic) NSMutableArray *relationNumber;
@property (strong, nonatomic) NSMutableArray *relationArticle;

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
    
    self.detailLabel.text = @"";
    dispatch_queue_t queue = dispatch_queue_create("saveItems.queue", NULL);
    dispatch_async(queue, ^{
        NSAttributedString *attrStr;
        NSError *err = nil;
        attrStr = [[NSAttributedString alloc]
                                initWithData:[[_article valueForKey:@"detail"][_articleNumber] dataUsingEncoding:NSUTF8StringEncoding]
                                options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                                          NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                documentAttributes:nil error:&err];
        if(err) NSLog(@"Unable to parse label text: %@", err);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.detailLabel.attributedText = attrStr;
            self.detailLabel.font = [UIFont fontWithName:@"System" size:15];
            self.detailLabel.userInteractionEnabled = YES;
            self.detailLabel.tag = 101;
        });
    });
    
    _relationNumber = [NSMutableArray arrayWithArray:[self getRelationNumber]];
    if (_rerationCategoryArticle.count > 3) {
        self.relation1Label.text = [_rerationCategoryArticle valueForKey:@"title"][[_relationNumber[0] intValue]];
        self.relation2Label.text = [_rerationCategoryArticle valueForKey:@"title"][[_relationNumber[1] intValue]];
        self.relation3Label.text = [_rerationCategoryArticle valueForKey:@"title"][[_relationNumber[2] intValue]];
    } else {
        self.relation1Label.text = [_relationArticle valueForKey:@"title"][[_relationNumber[0] intValue]];
        self.relation2Label.text = [_relationArticle valueForKey:@"title"][[_relationNumber[1] intValue]];
        self.relation3Label.text = [_relationArticle valueForKey:@"title"][[_relationNumber[2] intValue]];
    }
    
    self.relation1Label.userInteractionEnabled = YES;
    self.relation1Label.tag = 200;
    
    self.relation2Label.userInteractionEnabled = YES;
    self.relation2Label.tag = 201;
    
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
            if (_rerationCategoryArticle.count > 3) {
                vc.url = [_rerationCategoryArticle valueForKey:@"link"][[_relationNumber[0] intValue]];
            } else {
                vc.url = [_relationArticle valueForKey:@"link"][[_relationNumber[0] intValue]];
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        case 201:
            if (_rerationCategoryArticle.count > 3) {
                vc.url = [_rerationCategoryArticle valueForKey:@"link"][[_relationNumber[1] intValue]];
            } else {
                vc.url = [_relationArticle valueForKey:@"link"][[_relationNumber[1] intValue]];
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        case 202:
            if (_rerationCategoryArticle.count > 3) {
                vc.url = [_rerationCategoryArticle valueForKey:@"link"][[_relationNumber[2] intValue]];
            } else {
                vc.url = [_relationArticle valueForKey:@"link"][[_relationNumber[2] intValue]];
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        default:
            break;
    }
}

- (NSArray *)getRelationNumber {
    NSMutableArray *array = [NSMutableArray array];
    if (_rerationCategoryArticle.count > 3) {
        for (int i=0; i<3; i++) {
            int count = (int)_rerationCategoryArticle.count;
            int num = (int)arc4random_uniform(count);
            [array addObject:[NSNumber numberWithInteger:num]];
        }
    } else {
        AKAFetchData *fetch = [[AKAFetchData alloc] init];
        _relationArticle = [NSMutableArray array];
        for (int i=0; i<3; i++) {
            [_relationArticle addObject:[fetch fetchRandomArticle][0]];
            [array addObject:[NSNumber numberWithInt:i]];
        }
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
