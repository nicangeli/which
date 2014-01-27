//
//  ResultsViewController.h
//  Which
//
//  Created by Nicholas Angeli on 27/01/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController

@property (nonatomic, strong) PFObject *game;
@property (nonatomic, strong) NSArray *gameQuestions;
@property (nonatomic) NSInteger score;

@end
