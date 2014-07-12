//
//  GWTEventDetailViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEventDetailViewController.h"
#import "GWTEventsViewController.h"

@interface GWTEventDetailViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end

@implementation GWTEventDetailViewController

static NSArray* attendingStatus;

-(instancetype)initWithEvent:(GWTEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;
        [self initAttendingArray];
        [self queryAttendingStatus];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.eventNameLabel setText:[self.event eventName]];
    [self.pickerView selectRow:4 inComponent:0 animated:YES];
    
    /*
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:leftSwipe];
     */
}

-(void)initAttendingArray {
    attendingStatus = [[NSMutableArray alloc] initWithObjects:@"Attending", @"Maybe Attending", @"Not Attending", @"Not Responded", nil];
}

-(void)queryAttendingStatus {
    PFQuery *attendingStatus = [PFQuery queryWithClassName:@"EventUsers"];
    [attendingStatus whereKey:@"eventID" equalTo:self.event.objectId];
    [attendingStatus whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [attendingStatus getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError* error) {
        if (!error) {
            self.currentAttendingStatus = object;
            [self.pickerView selectRow:[self.currentAttendingStatus[@"attendingStatus"] intValue] inComponent:0 animated:YES];
        }
        else {
            self.currentAttendingStatus = [PFObject objectWithClassName:@"EventUsers"];
            self.currentAttendingStatus[@"userID"] = [[PFUser currentUser] objectId];
            self.currentAttendingStatus[@"eventID"] = self.event.objectId;
            [self.pickerView selectRow:[self.currentAttendingStatus[@"attendingStatus"] intValue] inComponent:0 animated:YES];
        }
    }];
}

#pragma mark pickerview delegate methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [attendingStatus objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentAttendingStatus[@"attendingStatus"] = [NSNumber numberWithInt:row];
}

#pragma mark navigation

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.currentAttendingStatus saveInBackground];
}

-(void)swipeLeft:(UISwipeGestureRecognizer*)sender {
    //events page
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
