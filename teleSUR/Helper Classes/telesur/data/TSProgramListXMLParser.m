//
//  TSProgramListXMLParser.m
//  teleSUR
//
//  Created by Simkin on 19/03/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "TSProgramListXMLParser.h"

@implementation TSProgramListXMLParser

@synthesize delegate;

- (void) loadCurrentProgramationXML {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]];

    currentDay = [components weekday];
//    NSLog(@"%ld", (long)currentDay);

    [self startParse:@"http://static.telesurtv.net/xml/grilla/tvweb_esp.xml"];

}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if ( ([elementName isEqualToString:@"lunes"] && currentDay == 2 ) || ([elementName isEqualToString:@"martes"] && currentDay == 3 ) ||
        ([elementName isEqualToString:@"miercoles"] && currentDay == 4 ) || ([elementName isEqualToString:@"jueves"] && currentDay == 5 ) ||
        ([elementName isEqualToString:@"viernes"] && currentDay == 6 ) || ([elementName isEqualToString:@"sabado"] && currentDay == 7 ) ||
        ([elementName isEqualToString:@"domingo"] && currentDay == 1 ) ) {

        programList = [NSMutableArray array];
        isTodayListParsingFinish = NO;

    } else if ( programList && [elementName isEqualToString:@"programa"] && !isTodayListParsingFinish) {

        currentProgramListElement = [[TSProgramListElement alloc] init];

    } else if ( programList && currentProgramListElement ) {

        currentText = [[NSMutableString alloc] init];
        [currentText setString:@""];
//        NSLog(@"Start Processing Element: %@ -> %@", elementName, currentText);

    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ( programList  && currentProgramListElement ) {
        
        [currentText appendString:string];
//        NSLog(@"Processing Value: %@ - %@", string, currentText);
        
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ( programList && currentProgramListElement ) {
        
        if ( [elementName isEqualToString:@"nombre"] ) {
            currentProgramListElement.name = currentText;
        } else if ( [elementName isEqualToString:@"sinopsis"] ) {
            currentProgramListElement.summary = currentText;
        } else if ( [elementName isEqualToString:@"hora_ini"] ) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_MX"];
            
            [formatter setLocale:locale];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            currentProgramListElement.initialDate = [formatter dateFromString:[NSString stringWithFormat:@"%@", currentText]];
            
        } else if ( [elementName isEqualToString:@"hora_fin"] ) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_MX"];
            
            [formatter setLocale:locale];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            currentProgramListElement.endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@", currentText]];
            
        } else if ( [elementName isEqualToString:@"programa"] ) {

            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm"];

            currentProgramListElement.scheduleString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:currentProgramListElement.initialDate], [formatter stringFromDate:currentProgramListElement.endDate]];
            [programList addObject:currentProgramListElement];
            currentProgramListElement = nil;
            
        }
//        NSLog(@"End Processing Element: %@ - %@", elementName, currentText);
        
    } else if ( programList ) {
        
        isTodayListParsingFinish = YES;
        
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

    if ( [ delegate respondsToSelector:@selector( TSProgramListXML:didFinish: ) ] ) {
        [ delegate TSProgramListXML:self didFinish:programList ];
    }

}









- (void)startParse:(NSString *)url {
    //Set the status to parsing
    parsing = YES;
    
    //Initialise the receivedData object
    receivedData = [[NSMutableData alloc] init];
    
    //Create the connection with the string URL and kick it off
    NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
    [urlConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //Reset the data as this could be fired if a redirect or other response occurs
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //Append the received data each time this is called
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Start the XML parser with the delegate pointing at the current object
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
    [parser setDelegate:self];
    [parser parse];
    
    parsing = false;
}

@end
