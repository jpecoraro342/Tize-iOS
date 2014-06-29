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
#import "GWTEventDetailViewController.h"
#import "GWTEditEventViewController.h"
#import "GWTFriendsTableViewController.h"
#import "GWTAttendingTableViewController.h"

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
    }
    else {
        //create an add new cell
        cell.eventNameLabel.text = @"Create New Event";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)queryEvents {
    _eventsArray = [[NSMutableArray alloc] init];
    
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllEventsForUsersWeAreFollowing = [PFQuery queryWithClassName:@"Event"];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllEventsForUsersWeAreFollowing whereKey:@"host" matchesKey:@"following" inQuery:getAllFollowingEvents];
    /*[getAllEventsForUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFObject *object in objects) {
                [self.eventsArray addObject:object];
            }
            [self.tableView reloadData];
        }
    }];*/
    
    PFQuery *getAllEventsForCurrentUser = [PFQuery queryWithClassName:@"Event"];
    [getAllEventsForCurrentUser whereKey:@"host" equalTo:[PFUser currentUser].objectId];
    /*[getAllEventsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.eventsArray addObject:object];
            }
        }
        [self.tableView reloadData];
    }];*/
    
    PFQuery *eventsQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:getAllEventsForCurrentUser, getAllEventsForUsersWeAreFollowing, nil]];
    [eventsQuery orderByDescending:@"date"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
    if (cellIndex.row < [self.eventsArray count]) {
        GWTAttendingTableViewController* attendeeList = [[GWTAttendingTableViewController alloc] initWithEvent:[self.eventsArray objectAtIndex:cellIndex.row]];
        [self animateSwipeLeftView:attendeeList];
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer*)sender {
    CGPoint swipePoint = [sender locationInView:self.tableView];
    NSIndexPath *cellIndex = [self.tableView indexPathForRowAtPoint:swipePoint];
    if (cellIndex.row < [self.eventsArray count]) {
        if ([[self.eventsArray objectAtIndex:cellIndex.row] host] == [[PFUser currentUser] objectId]) {
            GWTEditEventViewController* editEvent = [[GWTEditEventViewController alloc] initWithEvent:[self.eventsArray objectAtIndex:cellIndex.row]];
            [self animateSwipeRightView:editEvent];
        }
        else {
            GWTEventDetailViewController* eventDetails = [[GWTEventDetailViewController alloc] initWithEvent:[self.eventsArray objectAtIndex:cellIndex.row]];
            [self animateSwipeRightView:eventDetails];
        }
    }
}

-(void)animateSwipeLeftView:(UIViewController*)toViewController {
    UIView * toView = toViewController.view;
    UIView * fromView = self.view;
    
    // Get the size of the view area.
    CGRect viewSize = fromView.frame;
    
    // Add the toView to the fromView
    [fromView.superview addSubview:toView];
    
    // Position it off screen.
    toView.frame = CGRectMake(320 , viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:0.4 animations:^{
        // Animate the views on and off the screen. This will appear to slide.
        fromView.frame =CGRectMake(-320 , viewSize.origin.y, 320, viewSize.size.height);
        toView.frame =CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self presentViewController:toViewController animated:NO completion:nil];
        }
    }];
}

-(void)animateSwipeRightView:(UIViewController*)toViewController {
    UIView * toView = toViewController.view;
    UIView * fromView = self.view;
    
    // Get the size of the view area.
    CGRect viewSize = fromView.frame;
    
    // Add the toView to the fromView
    [fromView.superview addSubview:toView];
    
    // Position it off screen.
    toView.frame = CGRectMake(-320 , viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:0.4 animations:^{
        // Animate the views on and off the screen. This will appear to slide.
        fromView.frame =CGRectMake(320 , viewSize.origin.y, 320, viewSize.size.height);
        toView.frame =CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self presentViewController:toViewController animated:NO completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
