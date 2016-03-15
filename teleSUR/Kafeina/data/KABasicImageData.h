//
//  KABasicImageData.h
//  La Jornada
//
//  Created by Simkin on 09/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KABasicImageData : NSObject



@property (nonatomic, strong) NSString *ID;//id
@property (nonatomic, strong) NSString *type;//kind
@property (nonatomic, strong) NSString *title;//header
@property (nonatomic, strong) NSString *summary;//caption
@property (nonatomic, strong) NSString *thumbURL;//snap
@property (nonatomic, strong) NSString *URL;//url




- (id)initWithDictionary:(NSDictionary *)rawData;




@end