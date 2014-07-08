//
//  GWTEditEventViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEditEventViewController.h"
#import "GWTEventsViewController.h"

@interface GWTEditEventViewController () <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *eventLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *eventTimeTextField;

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
    }
    else {
        self.eventTypeLabel.text = @"Create Event";
    }
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:leftSwipe];
}

#pragma mark private methods

-(void)cancelEdit {
    self.shouldSaveChanges = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)inviteFriends {
    
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
    }
    
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
    [self returnWithSwipeLeftAnimation];
}

-(void)returnWithSwipeLeftAnimation {
    UIView * toView = [[self presentingViewController] view];
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
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
