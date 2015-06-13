//
//  AKADetailViewController.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/13.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKADetailViewController.h"

@interface AKADetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation AKADetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [[_article valueForKey:@"category"] valueForKey:@"name"];
    self.titleLabel.text = [_article valueForKey:@"title"];
    
    NSError *err = nil;
    self.detailLabel.attributedText = [[NSAttributedString alloc]
                                       initWithData:[[_article valueForKey:@"detail"] dataUsingEncoding:NSUTF8StringEncoding]
                                       options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                                                 NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                       documentAttributes:nil error:&err];
    if(err) NSLog(@"Unable to parse label text: %@", err);
    self.detailLabel.font = [UIFont fontWithName:@"System" size:17];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
