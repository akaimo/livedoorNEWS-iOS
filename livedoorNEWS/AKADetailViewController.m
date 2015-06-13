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
    
    NSError *err = nil;
    self.detailLabel.attributedText = [[NSAttributedString alloc]
                                       initWithData:[[_article valueForKey:@"detail"][_articleNumber] dataUsingEncoding:NSUTF8StringEncoding]
                                       options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                                                 NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                       documentAttributes:nil error:&err];
    if(err) NSLog(@"Unable to parse label text: %@", err);
    self.detailLabel.font = [UIFont fontWithName:@"System" size:15];
    
    _relationNumber = [NSMutableArray arrayWithArray:[self getRelationNumber]];
    self.relation1Label.text = [_article valueForKey:@"title"][[_relationNumber[0] intValue]];
    self.relation2Label.text = [_article valueForKey:@"title"][[_relationNumber[1] intValue]];
    self.relation3Label.text = [_article valueForKey:@"title"][[_relationNumber[2] intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    switch (touch.view.tag) {
        case 100: {
            AKARssWebViewController *vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"RssWebViewController"];
            vc.url = [_article valueForKey:@"link"][_articleNumber];
            [self.navigationController pushViewController:vc animated:YES];
        }
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

@end
