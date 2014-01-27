//
//  ResultsViewController.m
//  Which
//
//  Created by Nicholas Angeli on 27/01/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@property (nonatomic, strong) IBOutlet UILabel *answerLabel;

@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSArray *answers;

@end

@implementation ResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom ;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *image = [UIImage imageNamed:@"navItem.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:46.0/255 green:204.0/255 blue:113.0/255 alpha:1.0];
    self.navigationItem.titleView = imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *answers = self.game[@"answers"];
    PFRelation *relation = [self.game relationForKey:@"answers"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.answers = objects;
        PFObject *ourAnswer = [self findAnswerWithScore:self.score/self.gameQuestions.count];
        self.answerLabel.text = ourAnswer[@"title"];
        self.descriptionLabel.text = ourAnswer[@"description"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(PFObject *)findAnswerWithScore:(NSInteger)score
{
    for(PFObject *answer in self.answers) {
        NSInteger answerScore = [answer[@"score"] intValue];
        if(answerScore == score) {
            return answer;
        }
    }
    return self.answers[self.answers.count];
}

@end
