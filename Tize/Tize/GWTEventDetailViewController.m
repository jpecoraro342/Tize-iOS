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
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTimeLabel;

@end

@implementation GWTEventDetailViewController

static NSArray* attendingStatus;

-(instancetype)init {
    self = [super init];
    if (self) {
        attendingStatus = [[NSMutableArray alloc] initWithObjects:@"Attending", @"Maybe Attending", @"Not Attending", @"Not Responded", nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.pickerView selectRow:4 inComponent:0 animated:YES];
}

-(void)reloadWithEvent:(GWTEvent *)event {
    self.event = event;
    [self updateFields];
    [self queryAttendingStatus];
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

-(void)updateFields {
    [self.eventNameLabel setText:[self.event eventName]];
    [self.eventDescriptionTextView setText:[self.event eventDetails]];
    [self.eventLocationLabel setText:[self.event locationName]];
    [self.eventStartTimeLabel setText:[self.event timeString]];
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
    self.currentAttendingStatus[@"attendingStatus"] = [NSNumber numberWithInteger:row];
}

#pragma mark navigation

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.currentAttendingStatus saveInBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
