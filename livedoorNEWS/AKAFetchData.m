//
//  AKAFetchData.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/13.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAFetchData.h"
#import "AppDelegate.h"

@implementation AKAFetchData

+ (void)fetch {
    AKAFetchData *fetchData = [[AKAFetchData alloc] init];
    NSArray *categoryArray = [fetchData fetchCategory];
    NSArray *categoryName = @[@"主要", @"国内", @"海外", @"IT 経済", @"芸能", @"スポーツ", @"映画", @"グルメ", @"女子", @"トレンド"];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.article = [NSMutableArray array];
    
    for (int i=0; i<categoryArray.count; i++) {
        // カテゴリーを抽出
        NSManagedObjectContext *category;
        for (int j=0; j<categoryArray.count; j++) {
            if ([[categoryArray valueForKey:@"name"][j] isEqualToString:categoryName[i]]) {
                category = categoryArray[j];
                break;
            }
        }
        NSArray *articleArray = [fetchData fetchUnreadArticleSort:category];
        [delegate.article addObject:articleArray];
    }
}


- (NSArray *)fetchCategory {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return records;
}

- (NSArray *)fetchArticle:(NSManagedObjectContext *)category {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return  records;
}

- (NSArray *)fetchArticleSort:(NSManagedObjectContext *)category {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return  records;
}

- (NSArray *)fetchUnreadArticleSort:(NSManagedObjectContext *)category {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"category == %@ && unread == %@", category, [NSNumber numberWithBool:YES]];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return  records;
}

- (NSArray *)fetchArticle {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return  records;
}

- (NSArray *)fetchSaveArticle {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"save == %@", [NSNumber numberWithBool:YES]];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return  records;
}

- (int)getArticleCount {
    int count = 0;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    [request setIncludesSubentities:NO];
    count = (int)[[AKACoreData sharedCoreData].managedObjectContext countForFetchRequest:request error:nil];
    return count;
}

- (NSArray *)fetchRandomArticle {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    [request setFetchOffset:(arc4random() % [self getArticleCount])];
    [request setFetchLimit:1];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return records;
}

- (NSArray *)fetchArticleWithCategory:(NSManagedObjectContext *)category title:(NSString *)title {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"category == %@ && unread == %@ && title CONTAINS %@", category, [NSNumber numberWithBool:YES], title];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    return  records;
}

@end
