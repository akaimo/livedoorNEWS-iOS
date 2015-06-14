//
//  AKATopViewController.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/12.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKATopViewController.h"
#import "AKACategoryViewController.h"
#import "AKASynchro.h"
#import "AKAFetchData.h"

@interface AKATopViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *articles;
@property (weak, nonatomic) IBOutlet UITableView *topTableView;

@end

@implementation AKATopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 次のViewの戻るボタンの設定 */
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    self.title = @"livedoor NEWS";
    [AKASynchro synchro];
    _articles = @[@"主要", @"国内", @"海外", @"IT 経済", @"芸能", @"スポーツ", @"映画", @"グルメ", @"女子", @"トレンド"];
    [AKAFetchData fetch];
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
    NSString *cellIdentifier = @"ArticleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _articles[indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Category" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Category"]) {
        AKACategoryViewController *categoryViewController = (AKACategoryViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = sender;
        categoryViewController.title = _articles[indexPath.row];
        categoryViewController.categoryNumber = (int)indexPath.row;
    }
}


@end
