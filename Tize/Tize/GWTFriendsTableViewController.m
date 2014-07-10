//
//  GWTFriendsTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTFriendsTableViewController.h"
#import "GWTEventsViewController.h"

@interface GWTFriendsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GWTFriendsTableViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        _listOfFriends = [[NSMutableArray alloc] init];
        [self queryFollowing];
    }
    return self;
}

-(instancetype)initWithEvent:(GWTEvent*)event {
    self = [super init];
    if (self) {
        _listOfFriends = [[NSMutableArray alloc] init];
        self.isInviteList = YES;
        self.event = event;
        [self queryFollowing];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, self.view.frame.size.width, 44)];
    
    //UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    
    if (self.isInviteList) {
        self.tableView.allowsMultipleSelection = YES;
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"Invite Friends" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
        [toolbar setItems:[NSArray arrayWithObjects:flex, friends, nil]];
    }
    
    [self.view addSubview:toolbar];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:rightSwipe];
}

-(void)inviteSelected {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    for (int i = 0; i < [selectedRows count]; i++) {
        PFObject *invite = [PFObject objectWithClassName:@"EventUsers"];
        invite[@"userID"] = [[self.listOfFriends objectAtIndex:[[selectedRows objectAtIndex:i] row]] objectId];
        invite[@"attendingStatus"] = [NSNumber numberWithInt:3];
        invite[@"eventID"] = self.event.objectId;
        [invite saveInBackground];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableview delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfFriends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.row < [self.listOfFriends count]) {
        cell.textLabel.text = [[self.listOfFriends objectAtIndex:indexPath.row] username];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark query

-(void)queryFollowing {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFUser *object in objects) {
                [self.listOfFriends addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark animation and navigation

-(void)swipeRight:(UISwipeGestureRecognizer*)sender {
    [self returnWithSwipeRightAnimation];
    //[self presentViewController:events animated:YES completion:nil];
}

-(void)returnWithSwipeRightAnimation {
    UIView * toView = [[self presentingViewController] view];
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
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
