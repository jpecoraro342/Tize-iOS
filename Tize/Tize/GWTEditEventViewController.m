//
//  GWTEditEventViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEditEventViewController.h"
#import "GWTEventsViewController.h"
#import "GWTTizeFriendsTableViewController.h"
#import "GWTBasePageViewController.h"
#import "GWTLocalNotificationManager.h"
#import "GWTInviteFriendsViewController.h"
#import "GWTContactsViewController.h"
#import "GWTInviteFriendsToEventCommand.h"
#import "GWTInviteGroupToEventCommand.h"
#import "GWTIconCell.h"

@interface GWTEditEventViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UILabel *eventTypeLabel;
@property (strong, nonatomic) UITextField *eventNameTextField;
@property (strong, nonatomic) UITextView *eventDescriptionTextView;
@property (strong, nonatomic) UITextField *eventLocationTextField;
@property (strong, nonatomic) UILabel *eventStartTimeLabel;
@property (strong, nonatomic) UILabel *eventEndTimeLabel;
@property (strong, nonatomic) UIButton *createEventButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIDatePicker* startDatePicker;
@property (strong, nonatomic) UIDatePicker* endDatePicker;

@property (assign, nonatomic) BOOL startDateShouldShow;
@property (assign, nonatomic) BOOL endDateShouldShow;

@property (assign, nonatomic) BOOL isEdit;
@property (assign, nonatomic) BOOL shouldSaveChanges;

@property (nonatomic, strong) NSArray *peopleToInvite;

@property (nonatomic, strong) UICollectionView *iconCollectionView;

@property (nonatomic, strong) NSArray *iconArray;

@end

@implementation GWTEditEventViewController {
    NSIndexPath *_indexPathForSelectedIcon;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.iconArray = kIconImages;
        self.isEdit = NO;
        self.shouldSaveChanges = YES;
        self.event = [[GWTEvent alloc] init];
        [self.event setHost:[[PFUser currentUser] objectId]];
        [self.event setHostName:[[PFUser currentUser] username]];
        [self.event setHostUser:[PFUser currentUser]];
        NSDate *startDate = [self nextHourDate:[NSDate date]];
        NSDate *endDate = [startDate dateByAddingTimeInterval:60*60];
        [self.event setStartDate:startDate];
        [self.event setEndDate:endDate];
        [self.event setIcon:self.iconArray[0]];
        
        self.friendInvites = [[GWTInviteFriendsToEventCommand alloc] init];
        self.groupInvites = [[GWTInviteGroupToEventCommand alloc] init];
    }
    return self;
}

-(void)reloadWithEvent:(GWTEvent *)event {
    self.startDateShouldShow = self.endDateShouldShow = NO;
    
    self.isEdit = YES;
    self.shouldSaveChanges = YES;
    self.event = event;
    
    self.eventTypeLabel.text = @"Edit Event";
    self.createEventButton.titleLabel.text = @"Update Event";
    
    self.friendInvites = [[GWTInviteFriendsToEventCommand alloc] initWithEventID:self.event.objectId];
    self.groupInvites = [[GWTInviteGroupToEventCommand alloc] initWithEventID:self.event.objectId];
    
    [self updateFields];
    [self selectIcon];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up pickers
    self.startDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 216)];
    [self.startDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.startDatePicker addTarget:self action:@selector(startDatePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.endDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 216)];
    [self.endDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.endDatePicker addTarget:self action:@selector(endDatePickerDateChanged:) forControlEvents:UIControlEventValueChanged];

    [self updateEventStartDate:self.event.startDate endDate:self.event.endDate];
    
    // Update Text Fields
    [self updateFields];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createEvent:)];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    navItem.leftBarButtonItem = cancel;
    navItem.rightBarButtonItem = done;
    [self.navigationBar setItems:@[navItem]];
    [self.navigationBar setBarTintColor:kNavBarColor];
    [self.navigationBar setTintColor:kNavBarTintColor];
    
    [self.navigationBar setTitleTextAttributes:kNavBarTitleDictionary];
    
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
                    return 44;
                case 3:
                    return self.startDateShouldShow ? 216 : 0;
                case 4:
                    return 44;
                case 5:
                    return self.endDateShouldShow ? 216 : 0;
                case 6:
                    return 120;
                case 7:
                    return 80;
                case 8:
                    return 55;
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
    return self.isEdit ? 2 : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 9;
        case 1:
            return 1;
    }
    return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    
    switch (section) {
        case 0:
            [headerView setBackgroundColor:[UIColor lightGrayColor]];
            break;
        case 1:
            [headerView setBackgroundColor:[UIColor colorWithRed:244/255.0f green:244/255.0f blue:244/255.0f alpha:1]];
            break;
    }

    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 1) {
        [cell addSubview:[self deleteButton]];
        return cell;
    }
    
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
                [cell addSubview:self.startDatePicker];
                cell.clipsToBounds = YES;
                break;
            }
            case 4: {
                [titleLabel setText:@"End Time:"];
                self.eventEndTimeLabel = [[UILabel alloc] initWithFrame:inputTextfield.frame];
                [self.eventEndTimeLabel setText:[self.event endTime]];
                [cell addSubview:self.eventEndTimeLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                inputTextfield = nil;
                break;
            }
            case 5: {
                [cell addSubview:self.endDatePicker];
                cell.clipsToBounds = YES;
                break;
            }
            case 6: {
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
            case 7: {
                cell = [self collectionViewTableCell];
                inputTextfield = nil;
                break;
            }
            case 8: {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 55)];
                titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 20, 55)];
                titleLabel.text = @"Invite Friends";
                inputTextfield = nil;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.clipsToBounds = YES;
                break;
            }
        }
    
    [cell addSubview:titleLabel];
    [cell addSubview:inputTextfield];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //add friends
    if (indexPath.row == 8) {
        [self inviteFriends];
        return;
    }
    if (indexPath.row == 2) {
        self.startDateShouldShow = !self.startDateShouldShow;
        [self.view endEditing:YES];
    }
    else if (indexPath.row == 4) {
        self.endDateShouldShow = !self.endDateShouldShow;
        [self.view endEditing:YES];
    }
    else {
        return;
    }
    
    [self updateTableView];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

-(void)updateTableView {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.iconArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GWTIconCell *cell = (GWTIconCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.iconArray[indexPath.row]];

    cell.checkMark.hidden = ![_indexPathForSelectedIcon isEqual:indexPath];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectIconAtIndexPath:indexPath];
    self.event.icon = self.iconArray[indexPath.row];
    //NSLog(@"%@ Icon Selected", self.iconArray[indexPath.row]);
}

-(void)selectIcon {
    for (int i = 0; i < [self.iconArray count]; i++) {
        if ([self.event.icon isEqualToString:self.iconArray[i]]) {
            [self selectIconAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        }
    }
}

-(void)selectIconAtIndexPath:(NSIndexPath*)indexPath {
    GWTIconCell *cell = (GWTIconCell*)[self.iconCollectionView cellForItemAtIndexPath:indexPath];
    GWTIconCell *oldSelectedCell = (GWTIconCell*)[self.iconCollectionView cellForItemAtIndexPath:_indexPathForSelectedIcon];
    cell.checkMark.hidden = NO;
    if (oldSelectedCell) {
        oldSelectedCell.checkMark.hidden = YES;
    }
    _indexPathForSelectedIcon = indexPath;
}

#pragma mark - Views

-(UIButton*)deleteButton {
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    [deleteButton setBackgroundColor:[UIColor colorWithRed:230/255.0f green:30/255.0f blue:30/255.0f alpha:1]];
    [deleteButton setTitle:@"Delete Event" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(showDeleteConfirmation:) forControlEvents:UIControlEventTouchUpInside];
    
    return deleteButton;
}

-(UITableViewCell *)collectionViewTableCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
    if (self.iconCollectionView) {
        [cell.contentView addSubview:self.iconCollectionView];
    }
    else {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.itemSize = CGSizeMake(68, 68);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.iconCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80) collectionViewLayout:layout];
        UINib *cellNib = [UINib nibWithNibName:@"GWTIconCell" bundle:nil];
        [self.iconCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"collectionCell"];
        self.iconCollectionView.backgroundColor = [UIColor whiteColor];
        self.iconCollectionView.showsHorizontalScrollIndicator = NO;
        self.iconCollectionView.dataSource = self;
        self.iconCollectionView.delegate = self;
        [cell.contentView addSubview:self.iconCollectionView];
    }
    return cell;
}

#pragma mark Picker View

-(void)startDatePickerDateChanged:(UIDatePicker *)pickerView {
    NSDate *newStartDate = pickerView.date;
    NSDate *newEndDate = [self.event.endDate dateByAddingTimeInterval:[newStartDate timeIntervalSinceDate:self.event.startDate]];
    
    [self updateEventStartDate:newStartDate endDate:newEndDate];
}

-(void)endDatePickerDateChanged:(UIDatePicker *)pickerView {
    NSDate *newStartDate = self.event.startDate;
    NSDate *newEndDate = pickerView.date;
    
    if ([self.event.startDate compare:pickerView.date] == NSOrderedDescending) {
        newStartDate = [self.event.startDate dateByAddingTimeInterval:[newEndDate timeIntervalSinceDate:self.event.endDate]];
    }
    
    [self updateEventStartDate:newStartDate endDate:newEndDate];
}

-(void)updateEventStartDate:(NSDate *)startDate endDate:(NSDate*)endDate {
    [self.startDatePicker setDate:startDate];
    [self.endDatePicker setDate:endDate];
    
    [self.event setStartDate:startDate];
    [self.event setEndDate:endDate];
    
    [self.eventStartTimeLabel setText:self.event.startTime];
    [self.eventEndTimeLabel setText:self.event.endTime];
}

#pragma mark action sheet actions

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self deleteEvent];
    }
    return;
}

#pragma mark private methods

- (NSDate*) nextHourDate:(NSDate*)inDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate: inDate];
    [comps setHour: [comps hour]+1]; // Here you may also need to check if it's the last hour of the day
    return [calendar dateFromComponents:comps];
}

-(void)cancelEdit {
    [self.view endEditing:YES];
    self.shouldSaveChanges = NO;
    if (self.isEdit) {
        [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)createEvent:(id)sender {
    [self.view endEditing:YES];
    if ([self validateFields]) {
        [(GWTBasePageViewController*)self.parentViewController createdEvent:self.event];
        [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!error) {
                if (succeeded) {
                    [self sendOutInvites:self.event];
                    if (!self.isEdit) {
                        [[[GWTLocalNotificationManager alloc] init] scheduleNotificationForEvent:self.event];
                        self.eventCreated(self.event);
                    }
                }
            }
            else {
                NSLog(@"\nError: %@", error.localizedDescription);
            }
        }];
        if (self.isEdit) {
            [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)showDeleteConfirmation:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this event? (This cannot be undone)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

-(void)deleteEvent {
    [(GWTBasePageViewController*)self.parentViewController deleteEvent:self.event];
    [(GWTBasePageViewController*)self.parentViewController goForwardToEventsPage];
    [self.event deleteInBackground];
}

-(void)inviteFriends {
    [self updateEvent];
    //TODO: Use Factory Method
    GWTContactsViewController *friends = [[GWTContactsViewController alloc] initAsEventInviteWithGroupCommand:self.groupInvites friendCommand:self.friendInvites];
    [self presentViewController:friends animated:YES completion:nil];
}

-(void)updateFields {
    self.startDatePicker.date = self.event.startDate ?: [NSDate new];
    self.endDatePicker.date = self.event.endDate ?: [NSDate new];
    
    [self.eventNameTextField setText:[self.event eventName]];
    [self.eventDescriptionTextView setText:[self.event eventDetails]];
    [self.eventLocationTextField setText:[self.event locationName]];
    [self.eventStartTimeLabel setText:[self.event startTime]];
    [self.eventEndTimeLabel setText:[self.event endTime]];
}

-(BOOL)validateFields {
    if (![self validateEmpty:self.eventNameTextField.text withMessage:@"Event name cannot be blank"])
        return NO;
    if (![self validateEmpty:self.eventLocationTextField.text withMessage:@"Event location cannot be blank"])
        return NO;
    //if (![self validateEmpty:self.eventDescriptionTextView.text withMessage:@"Event description cannot be blank!"])
       // return NO;
    if (![self validateStartBeforeEnd])
        return NO;
    
    return YES;
}

-(BOOL)validateEmpty:(NSString*)text withMessage:(NSString*)alertMessage {
    if (text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Could not create event" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

-(BOOL)validateStartBeforeEnd {
    NSDate *date = self.startDatePicker.date;
    NSDate *endDate = self.endDatePicker.date;
    
    if ([date compare:endDate] == NSOrderedDescending) {
        [[[UIAlertView alloc] initWithTitle:@"Could Not Create Event" message:@"Start date must be before end date" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

-(void)updateEvent {
    [self.event setEventName:self.eventNameTextField.text];
    [self.event setLocationName:self.eventLocationTextField.text];
    [self.event setStartDate:self.startDatePicker.date];
    [self.event setEndDate:self.endDatePicker.date];
}

-(void)sendOutInvites:(GWTEvent*)event {
    self.friendInvites.eventId = [self.event objectId];
    self.groupInvites.eventId = [self.event objectId];
    
    [self.friendInvites execute];
    [self.groupInvites execute];
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

-(NSString*)description {
    return [NSString stringWithFormat:@"Edit Event VC"];
}

@end
