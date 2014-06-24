//
//  GWTEventsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import "GWTEventsViewController.h"
#import "GWTEventCell.h"
#import "GWTEvent.h"

@interface GWTEventsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* eventsArray;

@end

@implementation GWTEventsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self queryEvents];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *eventCell = [UINib nibWithNibName:@"GWTEventCell" bundle:nil];
    [self.tableView registerNib:eventCell forCellReuseIdentifier:@"eventCell"];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.tableView addGestureRecognizer:rightSwipe];
    [self.tableView addGestureRecognizer:leftSwipe];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blueBackground.png"]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventsArray count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GWTEventCell* cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    if (indexPath.row < [self.eventsArray count]) {
        GWTEvent* tempEvent = [self.eventsArray objectAtIndex:indexPath.row];
        cell.eventNameLabel.text = tempEvent.eventName;
        cell.eventLocationLabel.text = tempEvent.locationName;
        cell.eventTimeLabel.text = [tempEvent timeString];
    }
    else {
        //create an add new cell
        cell.eventNameLabel.text = @"";
        cell.eventLocationLabel.text = @"Create New Event";
        cell.eventTimeLabel.text = @"";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)queryEvents {
    _eventsArray = [[NSMutableArray alloc] init];
    
    PFQuery *getAllEventsForCurrentUser= [PFQuery queryWithClassName:@"Event"];
    PFQuery *getAllEventsForUsersWeAreFollowing = [PFQuery queryWithClassName:@"Event"];
    
    [getAllEventsForCurrentUser whereKey:@"host" equalTo:[PFUser currentUser].objectId];
    [getAllEventsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.eventsArray addObject:object];
            }
        }
        [self.tableView reloadData];
    }];
    
}

-(void)swipeLeft:(UISwipeGestureRecognizer*)sender {
    CGPoint swipePoint = [sender locationInView:self.tableView];
    NSIndexPath *cellIndex = [self.tableView indexPathForRowAtPoint:swipePoint];
    NSLog(@"Left swipe detected on row: %i", cellIndex.row);
}

-(void)swipeRight:(UISwipeGestureRecognizer*)sender {
    CGPoint swipePoint = [sender locationInView:self.tableView];
    NSIndexPath *cellIndex = [self.tableView indexPathForRowAtPoint:swipePoint];
    NSLog(@"Right swipe detected on row: %i", cellIndex.row);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
