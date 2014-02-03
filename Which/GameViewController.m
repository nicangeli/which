//
//  GameViewController.m
//  Which
//
//  Created by Nicholas Angeli on 27/01/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import "GameViewController.h"
#import "ResultsViewController.h"
#import "CustomCollectionViewCell.h"

@interface GameViewController ()

@end

@interface GameViewController ()

@property (strong, nonatomic) IBOutlet UILabel *currentGameTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentQuestionTitleLabel;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *currentOptions; // holds the pfobjects of the options
@property (nonatomic, strong) NSMutableArray *currentOptionsLabels; // holds the UILabel objects for the options

@property (strong, nonatomic) NSArray *questions; //holds all the questions for the entire game
@property (strong, nonatomic) PFObject *currentQuestion;
@property (nonatomic, strong) PFObject *selectedOption;

@property (nonatomic) NSInteger score;


@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentOptions = [NSMutableArray array];
    self.currentOptionsLabels = [NSMutableArray array];
    
    [self.currentGameTitleLabel setFont:[UIFont fontWithName:@"BlendaScript" size:20.0]];
    [self.currentQuestionTitleLabel setFont:[UIFont fontWithName:@"Raleway" size:20.0]];
    self.currentQuestionTitleLabel.backgroundColor = [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:0.5];
    [self.currentQuestionTitleLabel.layer setBorderWidth:5.0];
    [self.currentQuestionTitleLabel.layer setBorderColor:[[UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:0.5] CGColor]];
    self.currentGameTitleLabel.text = self.game[@"title"];
    self.currentGameTitleLabel.textColor = [UIColor colorWithRed:46.0/255 green:204.0/255 blue:113.0/255 alpha:1.0];
    
    
    PFRelation *questionsRelations = self.game[@"questions"];
    PFQuery *query = [questionsRelations query];
    // grab all of the questions to ask in this game
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.questions = objects;
        // grab all of the options to ask in this game
        [self displayQuestion:0];
        
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *image = [UIImage imageNamed:@"navItem.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    self.navigationItem.titleView = imageView;
    self.nextButton.hidden = YES;
    self.score = 0;
}


-(void)displayQuestion:(NSInteger)questionNumber
{
    // called when we want to change the question and options that are displayed...
    self.currentQuestion = self.questions[questionNumber];
    self.currentQuestionTitleLabel.text = self.currentQuestion[@"title"]; // change the question title
    
    self.nextButton.hidden = YES;
    [self removeViewsWithTag:1001 fromView:self.collectionView];
    [self removeViewsWithTag:333 fromView:self.collectionView];

    
    // got the questions already, now get the options
    PFRelation *questionToOptions = [self.currentQuestion relationForKey:@"options"];
    PFQuery *query = [questionToOptions query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.currentOptions = [NSMutableArray arrayWithArray:objects];
        NSMutableArray *optionLabels = [NSMutableArray array];
        for(PFObject *option in self.currentOptions) {
            [optionLabels addObject:[NSNull null]];
        }
        self.currentOptionsLabels = optionLabels;
        [self.collectionView reloadData];
        
    }];
}


-(IBAction)nextQuestionButton:(id)sender
{
    self.score += [self.selectedOption[@"score"] integerValue];
    
    // are we at the end of the game?
    if(([self.questions indexOfObject:self.currentQuestion] + 1) == self.questions.count) {
        // send us to the results page
        ResultsViewController *rvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Results"];
        rvc.game = self.game;
        rvc.gameQuestions = self.questions;
        rvc.score = self.score;
        [self.navigationController pushViewController:rvc animated:YES];
    } else { // not at the end of the game
        // increment the score
        [self displayQuestion:[self.questions indexOfObject:self.currentQuestion]+1];
    }
}

#pragma mark - collection view data source methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.currentOptions.count;
}

-(CustomCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.currentQuestion[@"type"] isEqualToString:@"image"]) {
        CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
        [cell.layer setBorderColor:[[UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0] CGColor]];
        [cell.layer setBorderWidth:6.0];
        
        PFObject *option = [self.currentOptions objectAtIndex:indexPath.item];
        PFFile *fileImage = option[@"image"];
        
        [fileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
            imgView.contentMode = UIViewContentModeRedraw;
            //imgView.contentMode = UIViewContentModeScaleToFill;
            imgView.tag = 1001;
            [cell addSubview:imgView];
        }];
        return cell;
    } else {
        CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TextCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor redColor];
        PFObject *option = [self.currentOptions objectAtIndex:indexPath.item];
        //cell.frame = CGRectMake(0, 30 * indexPath.item, 300, 30);
        cell.backgroundColor =[UIColor colorWithRed:46.0/255 green:204.0/255 blue:113.0/255 alpha:1.0];
        cell.titleLabel.text = option[@"title"];
        cell.titleLabel.font = [UIFont fontWithName:@"Raleway" size:18.0];
        cell.titleLabel.textColor = [UIColor whiteColor];
        //[cell.contentView addSubview:optionLabel];
        return cell;
    }
    return nil;
}

#pragma mark - collection view layoyut methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.currentQuestion[@"type"] isEqualToString:@"image"]) {
        return CGSizeMake(145, 126);
    } else {
        return CGSizeMake(300, 50);
    }
}

#pragma mark - long press gesture recognizer

-(IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if(indexPath != nil) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *v = (UIImageView *)[cell viewWithTag:1001];
            UIImageView *pop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, self.view.bounds.size.height - 300)];
            pop.image = v.image;
            pop.tag = 1002;
            pop.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:pop];
        }
    }
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self removeViewsWithTag:1002 fromView:self.view];
    }
}

#pragma mark - handle tap gesture recognizer

-(IBAction)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];

        
    if(indexPath != nil) {
        
        // track the curretn tapped item
        PFObject *selectedObject = self.currentOptions[indexPath.item];
        self.selectedOption = selectedObject;
        
        
        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        // do we want to display the check mark?
        
        // display the next button
        self.nextButton.hidden = NO;
        
        // remove all checkmarks
        [self removeViewsWithTag:333 fromView:self.collectionView];
        
        // set all checked properties to NO
        for(CustomCollectionViewCell *c in self.collectionView.subviews) {
            if([c isKindOfClass:[CustomCollectionViewCell class]]) {
                c.checked = NO;
            }
        }
        // for just the clicked cell, show the checkmark
        cell.checked = YES;
        UIImage *check = [UIImage imageNamed:@"check"];
        UIImageView *view = [[UIImageView alloc] initWithImage:check];
        view.frame = CGRectMake(cell.frame.size.width-50, 0, 50, 50);
        view.alpha = 0.5;
        view.tag = 333;
            
        [cell addSubview:view];
    }
}

#pragma  mark - misc functions

-(void)removeViewsWithTag:(NSInteger )tag fromView:(UIView *)view {
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return;
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        if(subview.tag == tag) {
            [subview removeFromSuperview];
        }
        
        // List the subviews of subview
        [self removeViewsWithTag:tag fromView:subview];
    }
}

@end