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

@interface GWTEditEventViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate>

@property (strong, nonatomic) UILabel *eventTypeLabel;
@property (strong, nonatomic) UITextField *eventNameTextField;
@property (strong, nonatomic) UITextView *eventDescriptionTextView;
@property (strong, nonatomic) UITextField *eventLocationTextField;
@property (strong, nonatomic) UILabel *eventStartTimeLabel;
@property (strong, nonatomic) UILabel *eventEndTimeLabel;
@property (strong, nonatomic) UIButton *createEventButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
        [_event setStartDate:[NSDate date]];
    }
    return self;
}

-(void)reloadWithEvent:(GWTEvent *)event {
    self.isEdit = YES;
    self.shouldSaveChanges = YES;
    self.event = event;
    
    self.eventTypeLabel.text = @"Edit Event";
    self.createEventButton.titleLabel.text = @"Update Event";
    
    [self updateFields];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateFields];
    
    //should we have two pickers for the two different dates?
    _picker = [[UIDatePicker alloc] init];
    [self.picker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.picker setDate:[self.event startDate]];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
    [cancel setTintColor:[UIColor darkGrayColor]];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createEvent:)];
    [done setTintColor:[UIColor darkGrayColor]];
    
    [self.navigationBar setBarTintColor:kNavBarColor];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    navItem.leftBarButtonItem = cancel;
    navItem.rightBarButtonItem = done;
    [self.navigationBar setItems:@[navItem]];
    
    self.eventTypeLabel.text = @"Create Event";
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark Table View

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                case 3:
                    return 44;
                case 4:
                    return 120;
            }
        }
        case 1:
        case 2:
        default:
            return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    //set title label text
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextField *inputTextfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 12, 310, 28)];
    inputTextfield.delegate = self;
    inputTextfield.borderStyle = UITextBorderStyleNone;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 200, 10)];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    switch (indexPath.row) {
        case 0: {
            [titleLabel setText:@"Event Name: "];
            self.eventNameTextField = inputTextfield;
            [inputTextfield setText:self.event.eventName];
            break;
        }
        case 1: {
            [titleLabel setText:@"Location:"];
            self.eventLocationTextField = inputTextfield;
            [inputTextfield setText:self.event.locationName];
            break;
        }
        case 2: {
            [titleLabel setText:@"Start Time:"];
            self.eventStartTimeLabel = [[UILabel alloc] initWithFrame:inputTextfield.frame];
            [self.eventStartTimeLabel setText:[self.event startTime]];
            [cell addSubview:self.eventStartTimeLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            inputTextfield = nil;
            break;
        }
        case 3: {
            [titleLabel setText:@"End Time:"];
            self.eventEndTimeLabel = [[UILabel alloc] initWithFrame:inputTextfield.frame];
            [self.eventEndTimeLabel setText:[self.event startTime]];
            [cell addSubview:self.eventEndTimeLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            inputTextfield = nil;
            break;
        }
        case 4: {
            [titleLabel setText:@"About:"];
            self.eventDescriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 14, self.tableView.frame.size.width-20, 100)];
            [self.eventDescriptionTextView setText:[self.event eventDetails]];
            self.eventDescriptionTextView.editable = YES;
            self.eventDescriptionTextView.scrollEnabled = NO;
            self.eventDescriptionTextView.delegate = self;
            [cell addSubview:self.eventDescriptionTextView];
            inputTextfield = nil;
            break;
        }
    }
    
    [cell addSubview:titleLabel];
    [cell addSubview:inputTextfield];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell Selected: %zd", indexPath.row);
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark private methods

-(void)cancelEdit {
    self.shouldSaveChanges = NO;
    if (self.isEdit) {
        [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)createEvent:(id)sender {
    [self.event saveInBackground];
    if (self.isEdit) {
        [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    [self.eventStartTimeLabel setText:[self.event startTime]];
    [self.eventEndTimeLabel setText:[self.event endTime]];
}

-(void)updateEvent {
    [self.event setEventName:self.eventNameTextField.text];
    [self.event setLocationName:self.eventLocationTextField.text];
    [self.event setStartDate:self.picker.date];
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
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark keyboard movement

- (void)keyboardWillShow:(NSNotification *)notification {
    if ([self.eventDescriptionTextView isFirstResponder]) {
        //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        //[self.tableView scrollRectToVisible:cell.frame animated:YES];
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
        
        [UIView animateWithDuration:.3 animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = contentInsets;
        }];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
