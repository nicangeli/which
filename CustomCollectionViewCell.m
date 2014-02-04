//
//  CustomCollectionViewCell.m
//  Which
//
//  Created by Nicholas Angeli on 02/02/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSLog(@"Initializing");
        self.checked = NO;
    }
    return self;
}


@end
