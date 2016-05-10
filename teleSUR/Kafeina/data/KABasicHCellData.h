//
//  KABasicHCellData.h
//  La Jornada
//
//  Created by Simkin on 09/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KABasicCellData.h"

@interface KABasicHCellData : KABasicCellData

@property (nonatomic, strong) NSString *hCellID;
@property (nonatomic, strong) NSArray *htableElements;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UIPageControl *pager;
@property (nonatomic, assign) CGRect hTableFrame;
@property (nonatomic, assign) CGRect hPagerFrame;
@property (nonatomic, assign) CGRect hTableCustomSize;
@property (nonatomic, assign) uint hTableIndex;
@property (nonatomic, assign) BOOL pagerHidden;

@end