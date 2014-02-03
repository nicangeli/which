//
//  CustomCollectionViewCell.h
//  Which
//
//  Created by Nicholas Angeli on 02/02/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic) BOOL checked;

@end
