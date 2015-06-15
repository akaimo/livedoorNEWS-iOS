//
//  AKAMarkAsArticle.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/15.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAMarkAsArticle.h"
#import "AKACoreData.h"

@implementation AKAMarkAsArticle

//-- DBの既読・未読を更新する
- (void)changeUnread:(NSString *)link unread:(NSNumber *)unread {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"link == %@", link];
    NSArray *records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    for (NSMutableData *data in records) {
        [data setValue:unread forKey:@"unread"];
        [[AKACoreData sharedCoreData] saveContext];
        NSLog(@"DBへ反映(un)read");
    }
}

@end
