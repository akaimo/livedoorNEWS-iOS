//
//  AKASynchro.m
//  livedoorNEWS
//
//  Created by akaimo on 2015/06/12.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKASynchro.h"
#import "Define.h"

@interface AKASynchro () <NSXMLParserDelegate> {
    BOOL isItem, isTitle, isLink, isDescription, isDate;
    NSMutableString *title, *link, *description, *date;
}

@property (strong, nonatomic) NSMutableArray *articles;

@end

@implementation AKASynchro

+ (NSArray *)synchro {
    // TODO: URLからXMLを受け取り解析
    AKASynchro *synchro = [[AKASynchro alloc] init];
    synchro.articles = [[NSMutableArray array] mutableCopy];
    NSString *urlStr = [NSString stringWithFormat:@"http://news.livedoor.com/topics/rss/top.xml"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser.delegate = synchro;
    BOOL isSuccess = [parser parse];
    if (!isSuccess) {
        NSLog(@"Errer");
        return nil;
    }
    
    
    
    // TODO: 解析したデータをDBに保存
    
    return synchro.articles;
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
        NSLog(@"%@", string);
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
    NSLog(@"finish");
}

//-- エラー発生時
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"error");
}

//-- Dateをフォーマット
- (NSDate *)formatDate:(NSString *)dateStr {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
    NSDate *date = [formatter dateFromString:dateStr];
    return date;
}


@end
