//
//  AKAFetchData.h
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/13.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKACoreData.h"

@interface AKAFetchData : NSObject

+ (void)fetch;

- (NSArray *)fetchCategory;
- (NSArray *)fetchArticle:(NSManagedObjectContext *)category;
- (NSArray *)fetchArticle;
- (NSArray *)fetchSaveArticle;
- (NSArray *)fetchRandomArticle;
- (NSArray *)fetchSearchArticleWithCategory:(NSManagedObjectContext *)category title:(NSString *)title;
- (NSArray *)fetchSearchAllArticle:(NSString *)title;
- (NSArray *)fetchSearchSaveArticle:(NSString *)title;

@end
