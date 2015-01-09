//
//  NewsViewController.h
//  teleSUR
//
//  Created by Simkin on 26/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMultimediaDataDelegate.h"

@interface NewsViewController : UICollectionViewController <TSMultimediaDataDelegate, UICollectionViewDelegateFlowLayout> {


    @protected
        NSMutableArray *news;
}

@end
