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
    // TODO: categoryを取得
    NSArray *categoryArray = [fetchData fetchCategory];
    NSArray *categoryName = @[@"主要", @"国内", @"海外", @"IT 経済", @"芸能", @"スポーツ", @"映画", @"グルメ", @"女子", @"トレンド"];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.article = [NSMutableArray array];
    
    // TODO: categoryごとにarticleを取得
    for (int i=0; i<categoryArray.count; i++) {
        // カテゴリーを抽出
        NSManagedObjectContext *category;
        for (int j=0; j<categoryArray.count; j++) {
            if ([[categoryArray valueForKey:@"name"][j] isEqualToString:categoryName[i]]) {
                category = categoryArray[j];
                break;
            }
        }
        NSArray *articleArray = [fetchData fetchArticle:category];
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

@end
