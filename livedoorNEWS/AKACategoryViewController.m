//
//  AKACategoryViewController.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/12.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKACategoryViewController.h"
#import "AKASynchro.h"
#import "AppDelegate.h"
#import "AKADetailViewController.h"
#import "AKATableViewCell.h"
#import "AKAFetchData.h"

@interface AKACategoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (strong, nonatomic) NSArray *articles;

@end

@implementation AKACategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 次のViewの戻るボタンの設定
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    UINib *nib = [UINib nibWithNibName:@"AKATableViewCell" bundle:nil];
    [self.categoryTableView registerNib:nib forCellReuseIdentifier:@"Detail"];
    
    switch (_categoryNumber) {
        case 0:{
            // TODO: 要高速化
            AKAFetchData *fetch = [[AKAFetchData alloc] init];
            _articles = [NSArray arrayWithArray:[fetch fetchArticle]];
        }
            break;
            
        case 1:{
            // TODO: 要高速化
            AKAFetchData *fetch = [[AKAFetchData alloc] init];
            _articles = [NSArray arrayWithArray:[fetch fetchSaveArticle]];
        }
            break;
            
        default:{
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            _articles = [NSArray arrayWithArray:delegate.article[_categoryNumber - 2]];
        }
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Detail";
    AKATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = [_articles valueForKey:@"title"][indexPath.row];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    cell.dateLabel.text = [df stringFromDate:[_articles valueForKey:@"date"][indexPath.row]];
    
    [cell.titleLabel sizeToFit];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    CGFloat dateHeight = 15.0;
    CGFloat pad = 10.0 + 10.0;
    
    // titleの高さを取得
    CGFloat viewMargin = 20.0f;
    CGFloat viewWidth = _categoryTableView.frame.size.width - (viewMargin * 2);
    CGSize bounds = CGSizeMake(viewWidth, CGFLOAT_MAX);
    CGRect boundingRectTitle = [[_articles valueForKey:@"title"][indexPath.row] boundingRectWithSize:bounds options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17.0] forKey:NSFontAttributeName] context:nil];
    
    height = boundingRectTitle.size.height + dateHeight + pad;
    
    return height;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Detail" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Detail"]) {
        AKADetailViewController *detailViewController = (AKADetailViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = sender;
        detailViewController.article = _articles;
        detailViewController.articleNumber = (int)indexPath.row;
    }
}

@end
