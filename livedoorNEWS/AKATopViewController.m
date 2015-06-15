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
#import "Define.h"

@interface AKATopViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *articles;
@property (weak, nonatomic) IBOutlet UITableView *topTableView;
- (IBAction)tapRefresh:(id)sender;

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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.topTableView addSubview:refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _articles.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ArticleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = ALL;
            break;
            
        case 1:
            cell.textLabel.text = SAVE;
            break;
            
        default:
            cell.textLabel.text = _articles[indexPath.row - 2];
            break;
    }
    
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
        
        switch (indexPath.row) {
            case 0:
                categoryViewController.title = ALL;
                break;
                
            case 1:
                categoryViewController.title = SAVE;
                break;
                
            default:
                categoryViewController.title = _articles[indexPath.row - 2];
                break;
        }
        categoryViewController.categoryNumber = (int)indexPath.row;
    }
}


- (void)onRefresh:(UIRefreshControl *) refreshControl {
    [refreshControl beginRefreshing];
    
    [AKASynchro synchro];
    [AKAFetchData fetch];
    
    [refreshControl endRefreshing];
}


- (IBAction)tapRefresh:(id)sender {
    [AKASynchro synchro];
    [AKAFetchData fetch];
}
@end
