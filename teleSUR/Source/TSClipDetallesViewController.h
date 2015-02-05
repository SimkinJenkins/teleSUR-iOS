//
//  TSClipDetallesViewController.h
//  teleSUR
//
//  Created by David Regla on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClipListadoTableViewController.h"
#import "TSClipPlayerViewController.h"

@interface TSClipDetallesViewController : TSClipListadoTableViewController {

    @protected
    // Diccionario con la información del Item presentado en la vista de detalle
    NSDictionary *currentItem;

    UILabel *currentDownloadLabel;
    UIButton *currentSender;

    BOOL isDownloading;

    long expectedDownloadLength;
    NSString *strFilePath;
    NSString *strFileName;
    NSFileHandle *file;

    int lastDownloadPercent;
    NSString *fileSizeString;

    NSURLConnection *connection;

    UIImageView *thumb;

    TSClipPlayerViewController *playerController;
}

// Inicia la vista con el diccionario enviado
- (id)initWithData:(NSDictionary *)itemData;

@end