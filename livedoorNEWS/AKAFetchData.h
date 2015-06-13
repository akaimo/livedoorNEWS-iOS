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

@end
