//
//  GameViewController.h
//  Which
//
//  Created by Nicholas Angeli on 27/01/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) PFObject *game;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

-(IBAction)nextQuestionButton:(id)sender;

@end
