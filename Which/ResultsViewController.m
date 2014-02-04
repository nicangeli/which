//
//  ResultsViewController.m
//  Which
//
//  Created by Nicholas Angeli on 27/01/2014.
//  Copyright (c) 2014 NicholasAngeli. All rights reserved.
//

#import "ResultsViewController.h"
#import "GameTableViewController.h"

@import Social;

@interface ResultsViewController ()

@property (nonatomic, strong) IBOutlet UILabel *answerLabel;
@property (nonatomic, strong) IBOutlet UIImageView *answerImage;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSArray *answers;

@end

@implementation ResultsViewController
{
    PFObject *ourAnswer;
}

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
    self.navigationItem.titleView = imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.answerLabel.font = [UIFont fontWithName:@"Raleway" size:20];
    self.descriptionLabel.font = [UIFont fontWithName:@"Raleway" size:15];
    
    // set up the segue to the home screen when back is clicked
    self.navigationController.topViewController.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"   Home" style:UIBarButtonSystemItemEdit target:self action:@selector(moveHome)];
    
    
    PFRelation *relation = [self.game relationForKey:@"answers"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.answers = objects;
        ourAnswer = [self findAnswerWithScore:self.score/self.gameQuestions.count];
        self.answerLabel.text = [NSString stringWithFormat:@"You are %@", ourAnswer[@"title"]];
        self.descriptionLabel.text = ourAnswer[@"description"];
        
        PFFile *fileImage = ourAnswer[@"image"];
        NSLog(@"fileImage: %@", fileImage);
        [fileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.answerImage.contentMode = UIViewContentModeScaleAspectFit;
            self.answerImage.image = [UIImage imageWithData:data];
        }];

        
    }];
}

-(void)moveHome
{
    GameTableViewController *gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    [self.navigationController pushViewController:gvc animated:YES];
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

-(IBAction)postToFacebook:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString *facebookContent = [NSString stringWithFormat:@"I got %@ on Which %@", ourAnswer[@"title"], self.game[@"title"]];

        [controller setInitialText:facebookContent];
        [controller addImage:self.answerImage.image];
        [controller addURL:[NSURL URLWithString:@"http://www.getwhich.io"]];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

-(IBAction)postToTwitter:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *tweetContent = [NSString stringWithFormat:@"I got %@ on Which %@", ourAnswer[@"title"], self.game[@"title"]];
        [tweetSheet addImage:self.answerImage.image];
        [tweetSheet addURL:[NSURL URLWithString:@"http://www.getwhich.io"]];
        [tweetSheet setInitialText:tweetContent];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

@end
