//
//  TSHomeTableViewController.h
//  teleSUR
//
//  Created by Simkin on 28/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClipListadoHomeMenuTableVC.h"
#import "EasyTableView.h"
#import "MarqueeLabel.h"

@interface TSHomeTableViewController : TSClipListadoHomeMenuTableVC <EasyTableViewDelegate> {
    
    @protected
        EasyTableView *horizontalView;
    
        UIPageControl *pageControl;

        NSArray *secondSectionElements;

        CGRect originTableFrame;
        CGRect withHeaderTableFrame;

        BOOL originTableFrameInitialized;

        BOOL cancelNextHideLoader;

        MarqueeLabel *breakingNewsMarquee;

        float topTablePosition;
        float secondaryTablePosition;

}

@end
