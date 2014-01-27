//
//  GameViewController.h
//  Which
//
//  Created by Nicholas Angeli on 27/01/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) PFObject *game;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

-(IBAction)nextQuestionButton:(id)sender;

@end
