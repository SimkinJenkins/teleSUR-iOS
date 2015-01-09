//
//  TSClipCellStripView.m
//  teleSUR
//
//  Created by Hector Zarate on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSClipCellStripView.h"
#import "AsynchronousImageView.h"
#import "TSClipDetallesViewController.h"

@implementation TSClipCellStripView

@synthesize descripcion;

@synthesize  imagen, titulo, firma, tiempo;

@synthesize controlador;

@synthesize posicion;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
