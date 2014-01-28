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

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIButton *nextQuestionButton;

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
    [self.currentQuestionTitleLabel setFont:[UIFont fontWithName:@"BlendaScript" size:20.0]];
    self.currentGameTitleLabel.text = self.game[@"title"];
    
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.pageControl.currentPage = 0;
    
    
    PFRelation *questionsRelations = self.game[@"questions"];
    PFQuery *query = [questionsRelations query];
    // grab all of the questions to ask in this game
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.questions = objects;
        // grab all of the options to ask in this game
        [self displayQuestion:0];
        
    }];
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
        
        self.pageControl.numberOfPages = self.currentOptions.count;
        self.pageControl.currentPage = 0;
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.currentOptions.count, CGRectGetHeight(self.scrollView.frame));
        
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        
    }];

}

-(void)loadScrollViewWithPage:(NSInteger)page
{
    if(page >= self.currentOptions.count || page < 0) {
        return;
    }
    
    UILabel *label = [self.currentOptionsLabels objectAtIndex:page];
    if ((NSNull *)label == [NSNull null])
    {
        label = [[UILabel alloc] init];
        label.text = self.currentOptions[page][@"title"];
    }
    
    if (label.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        label.frame = frame;
        
        PFFile *fileImage = self.currentOptions[page][@"image"];
        [fileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
            CGRect iFrame = self.scrollView.frame;
            iFrame.origin.x = CGRectGetWidth(iFrame) * page;
            iFrame.origin.y = 0;
            imgView.frame = iFrame;
            [self.scrollView addSubview:imgView];
            [self.scrollView addSubview:label];
        }];
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *image = [UIImage imageNamed:@"navItem.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:46.0/255 green:204.0/255 blue:113.0/255 alpha:1.0];
    self.navigationItem.titleView = imageView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)nextQuestionButton:(id)sender
{
    self.score += self.pageControl.currentPage+1;
    // remove the uilabel views from the screen
    for(NSInteger i = 0; i < self.currentOptionsLabels.count; i++) {
        if(self.currentOptionsLabels[i] != [NSNull null]) {
            [self.currentOptionsLabels[i] removeFromSuperview];
        }
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

@end