//
//  GWTEditEventViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEditEventViewController.h"
#import "GWTEventsViewController.h"
#import "GWTFriendsTableViewController.h"
#import "GWTBasePageViewController.h"

@interface GWTEditEventViewController () <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *eventLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *eventTimeTextField;
@property (weak, nonatomic) IBOutlet UIButton *createEventButton;

@property (strong, nonatomic) UIDatePicker* picker;

@property (assign, nonatomic) BOOL isEdit;
@property (assign, nonatomic) BOOL shouldSaveChanges;

@end

@implementation GWTEditEventViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.isEdit = NO;
        self.shouldSaveChanges = YES;
        _event = [[GWTEvent alloc] init];
        [_event setHost:[[PFUser currentUser] objectId]];
        [_event setDate:[NSDate date]];
    }
    return self;
}

-(instancetype)initWithEvent:(GWTEvent *)event {
    self = [super init];
    if (self) {
        self.isEdit = YES;
        self.shouldSaveChanges = YES;
        self.event = event;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateFields];
    
    _picker = [[UIDatePicker alloc] init];
    [self.picker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.picker setDate:[self.event date]];
    self.eventTimeTextField.inputView = self.picker;
    
    UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 49, self.view.frame.size.width, 49)];
    [self.view addSubview:bottomBar];
    
    UIBarButtonItem *inviteFriends = [[UIBarButtonItem alloc] initWithTitle:@"Invite Friends" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteFriends)];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [bottomBar setItems:[NSArray arrayWithObjects:inviteFriends, flex, cancel, nil]];
    
    if (self.isEdit) {
        self.eventTypeLabel.text = @"Edit Event";
        self.createEventButton.titleLabel.text = @"Update Event";
    }
    else {
        self.eventTypeLabel.text = @"Create Event";
    }
    /*
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:leftSwipe];
     */
}

#pragma mark private methods

-(void)cancelEdit {
    self.shouldSaveChanges = NO;
    [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
}

- (IBAction)createEvent:(id)sender {
    [self.event saveInBackground];
    [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
}

- (IBAction)deleteEvent:(id)sender {
    [self.event deleteInBackground];
    [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
}

-(void)inviteFriends {
    [self updateEvent];
    GWTFriendsTableViewController *friends = [[GWTFriendsTableViewController alloc] initWithEvent:self.event];
    [self presentViewController:friends animated:YES completion:nil];
}

-(void)updateFields {
    [self.eventNameTextField setText:[self.event eventName]];
    [self.eventDescriptionTextView setText:[self.event eventDetails]];
    [self.eventLocationTextField setText:[self.event locationName]];
    [self.eventTimeTextField setText:[NSString stringWithFormat:@"%@", [self.event date]]];
}

-(void)updateEvent {
    [self.event setEventName:self.eventNameTextField.text];
    [self.event setLocationName:self.eventLocationTextField.text];
    [self.event setDate:self.picker.date];
}

#pragma mark textview and textfield delegates

-(IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateEvent];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self.event setEventDetails:textView.text];
}

#pragma mark view lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    /*
    if (self.shouldSaveChanges) {
        [self.event saveInBackground];
    }
    else {
        if (self.isEdit) {
            [self.event fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    self.event = (GWTEvent*)object;
                }
            }];
        }
    }*/
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard movement

- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.view.frame;
        f.origin.y -= 60;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.view.frame;
        f.origin.y += 60;
        self.view.frame = f;
    }];
}

#pragma mark page navigation

-(void)swipeLeft:(UISwipeGestureRecognizer*)sender {
    //events page
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
