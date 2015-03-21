//
//  TSProgramListXMLParser.h
//  teleSUR
//
//  Created by Simkin on 19/03/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSProgramListElement.h"
#import "TSProgramListXMLParser.h"

@class TSProgramListXMLParser;
// Delegate
@protocol TSProgramListXMLParserDelegate <NSObject>

- (void) TSProgramListXML:(TSProgramListXMLParser *)parser didFinish:(NSMutableArray *)data;

@end

@interface TSProgramListXMLParser : NSObject <NSXMLParserDelegate> {

    id <TSProgramListXMLParserDelegate> delegate;

    @protected

        NSInteger currentDay;

        NSMutableArray *programList;
        NSMutableString *currentText;

        TSProgramListElement *currentProgramListElement;

        BOOL isTodayListParsingFinish;

        BOOL parsing;

        NSMutableData *receivedData;

}

@property (nonatomic) id <TSProgramListXMLParserDelegate> delegate;

- (void) loadCurrentProgramationXML;

@end