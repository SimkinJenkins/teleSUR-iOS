//
//  TSMainHomeViewController.h
//  teleSUR
//
//  Created by Simkin on 17/02/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "KABasicHTableViewController.h"

#import "UIViewController+TSDataMG.h"
#import "TSDataRequest.h"
#import "TSDataManager.h"

#import "UIViewController+TSLoader.h"
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"
#import "TSNewsViewController.h"

#import "UIDropDownMenu.h"
#import "UIViewController+KAUtils.h"

#import "HiddenVideoPlayerController.h"
#import "TSClipDetallesViewController.h"

#import "UIView+TSHighlightedViewCell.h"
#import "TSUtils.h"
#import "KABasicHCellData.h"
#import "TSUtils.h"
#import "KABasicDoubleCellData.h"
#import "TSiPhoneNavigationController.h"

@interface TSMainHomeViewController : KABasicHTableViewController <TSDataManagerDelegate> {

    @protected
        NSArray *uDIRContent;
        uint videosCount;
        uint showsCount;
        NSIndexPath *selectedIndexPath;
        NSArray *highlightedElements;
}

@end
