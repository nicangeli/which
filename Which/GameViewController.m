//
//  GameViewController.m
//  Which
//
//  Created by Nicholas Angeli on 27/01/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import "GameViewController.h"
#import "ResultsViewController.h"

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
    self.score = 0;
    self.currentOptions = [NSMutableArray array];
    self.currentOptionsLabels = [NSMutableArray array];
    
    [self.currentGameTitleLabel setFont:[UIFont fontWithName:@"BlendaScript" size:20.0]];
    [self.currentQuestionTitleLabel setFont:[UIFont fontWithName:@"Raleway" size:20.0]];
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
}


-(void)displayQuestion:(NSInteger)questionNumber
{
    // called when we want to change the question and options that are displayed...
    self.currentQuestion = self.questions[questionNumber];
    self.currentQuestionTitleLabel.text = self.currentQuestion[@"title"]; // change the question title
    
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
    self.score += 1; //TODO the actual score
    
    // remove the uilabel views from the screen
    for(UIView *view in self.collectionView.subviews) {
        [view removeFromSuperview];
    }
    
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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    
    PFObject *option = [self.currentOptions objectAtIndex:indexPath.item];
    PFFile *fileImage = option[@"image"];
    
    [fileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.tag = 1001;
        [cell addSubview:imgView];
    }];
    return cell;
}

#pragma mark - long press gesture recognizer

-(IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        
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
        UIView *v = [self.view viewWithTag:1002];
        [v removeFromSuperview];
    }
}

#pragma mark - handle tap gesture recognizer

-(IBAction)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        if(indexPath != nil) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            UILabel *checkmark = [[UILabel alloc] init];
        }
        
    }
}

@end