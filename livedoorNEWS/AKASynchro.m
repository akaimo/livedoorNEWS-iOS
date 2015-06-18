//
//  AKASynchro.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/12.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKASynchro.h"
#import "Define.h"
#import "AKACoreData.h"
#import "AKAFetchData.h"

@interface AKASynchro () <NSXMLParserDelegate> {
    BOOL isItem, isTitle, isLink, isDescription, isDate;
    NSMutableString *title, *link, *description, *date;
}

@property (strong, nonatomic) NSMutableArray *articles;

@end

@implementation AKASynchro

+ (void)synchro {
    AKASynchro *synchro = [[AKASynchro alloc] init];
    NSArray *categoryName = @[@"主要", @"国内", @"海外", @"IT 経済", @"芸能", @"スポーツ", @"映画", @"グルメ", @"女子", @"トレンド"];
    NSArray *categoryURL = @[@"http://news.livedoor.com/topics/rss/top.xml",
                             @"http://news.livedoor.com/topics/rss/dom.xml",
                             @"http://news.livedoor.com/topics/rss/int.xml",
                             @"http://news.livedoor.com/topics/rss/eco.xml",
                             @"http://news.livedoor.com/topics/rss/ent.xml",
                             @"http://news.livedoor.com/topics/rss/spo.xml",
                             @"http://news.livedoor.com/rss/summary/52.xml",
                             @"http://news.livedoor.com/topics/rss/gourmet.xml",
                             @"http://news.livedoor.com/topics/rss/love.xml",
                             @"http://news.livedoor.com/topics/rss/trend.xml"];
    
    if (![synchro existCategory]) {
        // Categoryテーブルを作成する
        NSLog(@"unexist");
        [synchro createCategory:categoryName];
    }
    
    AKAFetchData *fetchData = [[AKAFetchData alloc] init];
    NSArray *categoryArray = [fetchData fetchCategory];
    for (int i=0; i<categoryArray.count; i++) {
        synchro.articles = [[NSMutableArray array] mutableCopy];
        NSString *urlStr = [NSString stringWithFormat:categoryURL[i]];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        parser.delegate = synchro;
        BOOL isSuccess = [parser parse];
        if (!isSuccess) {
            NSLog(@"Errer");
            return;
        }
        
        // カテゴリーを抽出
        NSManagedObjectContext *category;
        for (int j=0; j<categoryArray.count; j++) {
            if ([[categoryArray valueForKey:@"name"][j] isEqualToString:categoryName[i]]) {
                category = categoryArray[j];
                break;
            }
        }
        
        [synchro saveArticle:category];
    }
    
    [synchro deleteArticle];
}



# pragma mark - NSXMLParserDelegate
//-- 解析開始時
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    // フラグの初期化
    isItem          = NO;
    isTitle         = NO;
    isLink          = NO;
    isDescription   = NO;
    isDate          = NO;
}

//-- 要素の開始タグを読み込んだ時
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // フラグをたてる
    if ([ITEM isEqualToString:elementName]) isItem = YES;
    if (isItem) {
        if ([TITLE isEqualToString:elementName]) {
            isTitle = YES;
            title = [[NSMutableString string] mutableCopy];
        } else if ([LINK isEqualToString:elementName]) {
            isLink = YES;
            link = [[NSMutableString string] mutableCopy];
        } else if ([DESCRIPTION isEqualToString:elementName]) {
            isDescription = YES;
            description = [[NSMutableString string] mutableCopy];
        } else if ([DATE isEqualToString:elementName]) {
            isDate = YES;
            date = [[NSMutableString string] mutableCopy];
        }
    }
}

//-- 要素の終了タグを読み込んだ時
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    // itemタグを抜けるタイミングで1item分のNSDictionaryを作成し、articlesにつめる
    if ([ITEM isEqualToString:elementName]) {
        isItem = NO;
        NSDictionary *article = @{TITLE         : title,
                                  LINK          : link,
                                  DESCRIPTION   : description,
                                  @"date"       : [self formatDate:date]};
        [self.articles addObject:article];
    }
    if (isItem) {
        if ([TITLE isEqualToString:elementName]) {
            isTitle = NO;
        } else if ([LINK isEqualToString:elementName]) {
            isLink = NO;
        } else if ([DESCRIPTION isEqualToString:elementName]) {
            isDescription = NO;
        } else if ([DATE isEqualToString:elementName]) {
            isDate = NO;
        }
    }
}

//-- タグ以外のテキストを読み込んだ時
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (isTitle) {
        [title appendString:string];
    } else if (isLink) {
        [link appendString:string];
    } else if (isDescription) {
        [description appendString:string];
    } else if (isDate) {
        [date appendString:string];
    }
}

//-- 解析終了時
- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

//-- エラー発生時
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"error");
}


# pragma mark - Synchro
- (NSDate *)formatDate:(NSString *)dateStr {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
    NSDate *date = [formatter dateFromString:dateStr];
    return date;
}

- (BOOL)existCategory {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    if (records.count == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)createCategory:(NSArray *)categoryName {
    for (NSString *name in categoryName) {
        id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                               inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
        [obj setValue:name forKey:@"name"];
        [[AKACoreData sharedCoreData] saveContext];
    }
}

- (void)saveArticle:(NSManagedObjectContext *)category {
    AKAFetchData *fetchData = [[AKAFetchData alloc] init];
    NSArray *articleArray = [fetchData fetchArticle:category];
    
    // DBに存在しなければ保存
    for (NSDictionary *dic in _articles) {
        BOOL exist = NO;
        for (NSManagedObjectContext *article in articleArray) {
            if ([[article valueForKey:@"link"] isEqualToString:[dic valueForKey:@"link"]]) {
                exist = YES;
                break;
            }
        }
        
        if (!exist) {
            id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                   inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
            [obj setValue:[dic valueForKey:@"title"] forKey:@"title"];
            [obj setValue:[dic valueForKey:@"link"] forKey:@"link"];
            [obj setValue:[dic valueForKey:@"description"] forKey:@"detail"];
            [obj setValue:[dic valueForKey:@"date"] forKey:@"date"];
            [obj setValue:category forKey:@"category"];
            [[AKACoreData sharedCoreData] saveContext];
        }
    }
}

- (void)deleteArticle {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    comps.day = -4;
    NSDate *result = [calendar dateByAddingComponents:comps toDate:now options:0];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"save == %@ && date <= %@",[NSNumber numberWithBool:NO], result];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    if (records.count != 0) {
        for (NSManagedObject *data in records) {
            [[[AKACoreData sharedCoreData] managedObjectContext] deleteObject:data];
        }
        [[AKACoreData sharedCoreData] saveContext];
    }
}


@end
