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
#import "AKAMarkAsArticle.h"
#import "MBProgressHUD.h"

@interface AKACategoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)tapActionBtn:(id)sender;

@property (strong, nonatomic) NSArray *articles;                        // 該当カテゴリーの記事
@property (strong, nonatomic) NSMutableArray *searchResultsArticles;    // 検索結果の記事
@property (strong, nonatomic) NSNumber *noArticle;                      // 記事の存在を管理するフラグ

@end

@implementation AKACategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 次のViewの戻るボタンの設定
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    UINib *nib = [UINib nibWithNibName:@"AKATableViewCell" bundle:nil];
    [self.categoryTableView registerNib:nib forCellReuseIdentifier:@"Detail"];
    
    switch (_categoryNumber) {
        case 0:{    // All Items
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_queue_t queue = dispatch_queue_create("AllItems.queue", NULL);
            dispatch_async(queue, ^{
                AKAFetchData *fetch = [[AKAFetchData alloc] init];
                _articles = [NSArray arrayWithArray:[fetch fetchArticle]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [_categoryTableView reloadData];
                });
            });
        }
            break;
            
        case 1:{    // Save Items
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_queue_t queue = dispatch_queue_create("saveItems.queue", NULL);
            dispatch_async(queue, ^{
                AKAFetchData *fetch = [[AKAFetchData alloc] init];
                _articles = [NSArray arrayWithArray:[fetch fetchSaveArticle]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [_categoryTableView reloadData];
                });
            });
        }
            break;
            
        default:{
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            _articles = [NSArray arrayWithArray:delegate.article[_categoryNumber - 2]];
        }
            break;
    }
    
    // 検索バーを隠す
    [self.categoryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [_categoryTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索したとき
        count = _searchResultsArticles.count;
    } else {
        count = _articles.count;
    }
    
    // 記事の存在確認
    if (count == 0) {
        _noArticle = [NSNumber numberWithBool:YES];
        count++;
    } else {
        _noArticle = [NSNumber numberWithBool:NO];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Detail";
    AKATableViewCell *cell;
    
    [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    if ([_noArticle isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        // 記事が存在しないとき
        UINib *nib = [UINib nibWithNibName:@"AKATableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Detail"];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.titleLabel.text = @"記事が存在しません";
        cell.dateLabel.text = @"";
        return cell;
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索したとき
        tableView.separatorColor = [UIColor clearColor];    // 下線を消す
        
        UINib *nib = [UINib nibWithNibName:@"AKATableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"Detail"];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        cell.titleLabel.text = [_searchResultsArticles valueForKey:@"title"][indexPath.row];
        cell.titleLabel.textColor = [UIColor blackColor];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
        [df setDateFormat:@"yyyy/MM/dd HH:mm"];
        if ([[_searchResultsArticles valueForKey:@"save"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            cell.dateLabel.text = [NSString stringWithFormat:@"★ %@", [df stringFromDate:[_searchResultsArticles valueForKey:@"date"][indexPath.row]]];
        } else {
            cell.dateLabel.text = [df stringFromDate:[_searchResultsArticles valueForKey:@"date"][indexPath.row]];
        }
        cell.dateLabel.textColor = [UIColor darkGrayColor];
        
        [cell.titleLabel sizeToFit];
        
        if ([[_searchResultsArticles valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            cell.titleLabel.textColor = [UIColor lightGrayColor];
            cell.dateLabel.textColor = [UIColor lightGrayColor];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.titleLabel.text = [_articles valueForKey:@"title"][indexPath.row];
        cell.titleLabel.textColor = [UIColor blackColor];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
        [df setDateFormat:@"yyyy/MM/dd HH:mm"];
        if ([[_articles valueForKey:@"save"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            cell.dateLabel.text = [NSString stringWithFormat:@"★ %@", [df stringFromDate:[_articles valueForKey:@"date"][indexPath.row]]];
        } else {
            cell.dateLabel.text = [df stringFromDate:[_articles valueForKey:@"date"][indexPath.row]];
        }
        cell.dateLabel.textColor = [UIColor darkGrayColor];
        
        [cell.titleLabel sizeToFit];
        
        if ([[_articles valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            cell.titleLabel.textColor = [UIColor lightGrayColor];
            cell.dateLabel.textColor = [UIColor lightGrayColor];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_noArticle isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        // 記事が存在しないとき
        return 44.0;
    }
    
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
    if ([_noArticle isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        // 記事が存在しないとき
        return;
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 検索
        // 開いたときに既読にする
        if ([[_articles valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            dispatch_queue_t queue = dispatch_queue_create("read.queue", NULL);
            dispatch_async(queue, ^{
                AKAMarkAsArticle *mark = [[AKAMarkAsArticle alloc] init];
                [mark changeUnread:[_searchResultsArticles valueForKey:@"link"][indexPath.row] unread:[NSNumber numberWithBool:NO]];
                [_searchResultsArticles[indexPath.row] setValue:[NSNumber numberWithDouble:NO] forKey:@"unread"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.searchDisplayController.searchResultsTableView reloadData];
                });
            });
        }
        NSArray *array = [NSArray arrayWithObjects:indexPath, [NSNumber numberWithBool:YES], nil];
        [self performSegueWithIdentifier:@"Detail" sender:array];
    } else {
        // 開いたときに既読にする
        if ([[_articles valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            dispatch_queue_t queue = dispatch_queue_create("read.queue", NULL);
            dispatch_async(queue, ^{
                AKAMarkAsArticle *mark = [[AKAMarkAsArticle alloc] init];
                [mark changeUnread:[_articles valueForKey:@"link"][indexPath.row] unread:[NSNumber numberWithBool:NO]];
                [_articles[indexPath.row] setValue:[NSNumber numberWithDouble:NO] forKey:@"unread"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_categoryTableView reloadData];
                });
            });
        }
        NSArray *array = [NSArray arrayWithObjects:indexPath, [NSNumber numberWithBool:NO], nil];
        [self performSegueWithIdentifier:@"Detail" sender:array];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Detail"]) {
        AKADetailViewController *detailViewController = (AKADetailViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = sender[0];
        detailViewController.rerationCategoryArticle = _articles;
        detailViewController.articleNumber = (int)indexPath.row;
        
        if ([sender[1] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            // 検索
            detailViewController.article = _searchResultsArticles;
        } else {
            detailViewController.article = _articles;
        }
    }
}

- (void)markAllasRead {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_queue_t queue = dispatch_queue_create("markAllasRead.queue", NULL);
    dispatch_async(queue, ^{
        AKAMarkAsArticle *mark = [[AKAMarkAsArticle alloc] init];
        for (int i=0; i<_articles.count; i++) {
            [mark changeUnread:[_articles valueForKey:@"link"][i] unread:[NSNumber numberWithBool:NO]];
            [_articles[i] setValue:[NSNumber numberWithDouble:NO] forKey:@"unread"];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (void)filterContainsWithSearchText:(NSString *)searchText {
    _searchResultsArticles = [NSMutableArray array];
    AKAFetchData *fetch = [[AKAFetchData alloc] init];
    
    // 記事が存在するときのみ検索する
    if (_articles.count != 0) {
        switch (_categoryNumber) {
            case 0:     // All Items
                _searchResultsArticles = [NSMutableArray arrayWithArray:[fetch fetchSearchAllArticle:searchText]];
                break;
                
            case 1:     // Save Items
                _searchResultsArticles = [NSMutableArray arrayWithArray:[fetch fetchSearchSaveArticle:searchText]];
                break;
                
            default:
                _searchResultsArticles = [NSMutableArray arrayWithArray:[fetch fetchSearchArticleWithCategory:[_articles valueForKey:@"category"][0] title:searchText]];
                break;
        }
    }
}

- (BOOL)searchDisplayController:controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContainsWithSearchText:searchString];       // 検索
    return YES;     // リロード
}


- (IBAction)tapActionBtn:(id)sender {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:nil
                                                                 message:@"Mark all items from this list as read?"
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    UIAlertAction * destructiveAction = [UIAlertAction actionWithTitle:@"Mark All as Read"
                                                                 style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * action) {
                                                                   [self markAllasRead];
                                                               }];
    
    [ac addAction:cancelAction];
    [ac addAction:destructiveAction];
    
    [self presentViewController:ac animated:YES completion:nil];
}
@end
