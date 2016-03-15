//
//  KABasicHTableViewController.m
//  La Jornada
//
//  Created by Simkin on 09/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import "KABasicHTableViewController.h"

@implementation KABasicHTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    htables = [NSMutableArray array];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isTableItemHCellAtIndex:indexPath]) {
        NSString *cellID = [self getCellIDForIndex:indexPath];
        UITableViewCell *cell = [self setHTableAtCell:[self getReuseCell:tableView withID:cellID] forIndexPath:indexPath withID:cellID];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *) setHTableAtCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withID:(NSString *)cellID {
    KABasicHCellData *cellData = [tableItems objectAtIndex:indexPath.row];
    if ( !cellData.table ) {
        CGRect frameRect = !CGRectIsEmpty(cellData.hTableFrame) ? cellData.hTableFrame :
                            CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        EasyTableView *htable = [ [ EasyTableView alloc ] initWithFrame:frameRect numberOfColumns:[cellData.htableElements count ] ofWidth:!CGSizeEqualToSize(CGSizeZero, cellData.cellSize) ? cellData.cellSize.width : 320 ];
        cellData.hTableIndex = (int)[htables count];
        htable.tag = 8000 + cellData.hTableIndex;
        htable.delegate						= self;
        htable.tableView.backgroundColor      = [UIColor whiteColor];
        htable.tableView.allowsSelection      = YES;
        htable.tableView.separatorColor		= [UIColor clearColor];
        htable.tableView.pagingEnabled        = YES;
        htable.cellBackgroundColor			= [UIColor clearColor];
        cellData.table = (UITableView *)htable;
        UIPageControl *pager = [[UIPageControl alloc] initWithFrame: !CGRectIsEmpty(cellData.hPagerFrame) ? cellData.hPagerFrame :CGRectMake(0, frameRect.origin.y + frameRect.size.height - 25, frameRect.size.width, 20)];
        pager.numberOfPages = [cellData.htableElements count];
        pager.currentPage = 0;
        pager.hidden = NO;
        pager.enabled = NO;
        pager.tag = 8100 + cellData.hTableIndex;
        cellData.pager = pager;
        [htables addObject:cellData];
    }
    [[cell.contentView viewWithTag:8000 + cellData.hTableIndex] removeFromSuperview];
    [[cell.contentView viewWithTag:8100 + cellData.hTableIndex] removeFromSuperview];
    [[cell.contentView viewWithTag:8001 + cellData.hTableIndex] removeFromSuperview];
    [[cell.contentView viewWithTag:8101 + cellData.hTableIndex] removeFromSuperview];
    [cell.contentView addSubview:cellData.table];
    [cell.contentView addSubview:cellData.pager];
    return cell;
}

- (NSString *) getCellIDForIndex:(NSIndexPath *)indexPath {
    if ( [self isTableItemHCellAtIndex:indexPath]) {
        KABasicHCellData *data = [tableItems objectAtIndex:indexPath.row];
        if ( data.cellID ) {
            return data.cellID;
        }
        return @"KABasicHTableCellView";
    }
    return [super getCellIDForIndex:indexPath];
}

- (BOOL) isTableItemHCellAtIndex:(NSIndexPath *)indexPath {
    return [[tableItems objectAtIndex:indexPath.row] isKindOfClass:[KABasicHCellData class]];
}

- (NSString *) getHTableCellViewID {
    return @"KABasicHTableHCellView";
}





























#pragma mark -
#pragma mark EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
    NSString *htableID = [self getHTableCellViewID];
    KABasicHCellData *hData = [self getDataForHTable:easyTableView];
    if ( hData.hCellID ) {
        htableID = hData.hCellID;
    }
    return [self getReuseCell:easyTableView.tableView withID:htableID].contentView;
}

- (void)easyTableView:(EasyTableView *)easyTableView scrolledToFraction:(CGFloat)fraction {
    KABasicHCellData *hData = [self getDataForHTable:easyTableView];
    hData.pager.currentPage = round(fraction * ([hData.htableElements count] - 1));
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath {
    KABasicHCellData *hData = [self getDataForHTable:easyTableView];
    KABasicHCellData *hcellData = [hData.htableElements objectAtIndex:indexPath.row];
    if ( !hcellData.cellID ) {
        hcellData.cellID = [hData.hCellID copy];
    }
    [self configureCell:view withData:hcellData];
    [self configureCellImage:view withData:hcellData];
}

- (KABasicHCellData *) getDataForHTable:(EasyTableView *)tableView {
    for (uint i = 0; i < [htables count]; i++) {
        KABasicHCellData *hData = [htables objectAtIndex:i];
        if ( tableView == (EasyTableView *)hData.table ) {
            return hData;
        }
    }
    return nil;
}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {
    [self didSelectRowWithData:[[self getDataForHTable:easyTableView].htableElements objectAtIndex:indexPath.row]];
}

@end