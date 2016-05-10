//
//  KABasicTableCellData.h
//  La Jornada
//
//  Created by Simkin on 09/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KABasicImageData.h"

@interface KABasicCellData : NSObject


@property (nonatomic, assign) uint cellIndex;
@property (nonatomic, strong) NSString *ID;//id, uid
@property (nonatomic, strong) NSString *type;//id, uid
@property (nonatomic, strong) NSString *title;//edTitle, title
@property (nonatomic, strong) NSString *summary;//summary
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *cellID;
@property (nonatomic, strong) NSString *URL;

@property (nonatomic, strong) NSObject *rawData;

@property (nonatomic, strong) NSArray *images;//images

@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, assign) BOOL cancelUserInteraction;







- (id) initWithDictionary:(NSDictionary *)rawData;



@end