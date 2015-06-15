//
//  AKAMarkAsArticle.h
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/15.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAMarkAsArticle : NSObject

- (void)changeUnread:(NSString *)link unread:(NSNumber *)unread;
- (void)changeSave:(NSString *)link save:(NSNumber *)save;

@end
