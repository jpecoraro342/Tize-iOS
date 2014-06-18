//
//  GWTEventsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blueBackground.png"]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventsArray count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GWTEventCell* cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    if (indexPath.row < [self.eventsArray count]) {
        GWTEvent* tempEvent = [self.eventsArray objectAtIndex:indexPath.row];
        cell.eventNameLabel.text = tempEvent.name;
        cell.eventLocationLabel.text = tempEvent.location;
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
    
    GWTEvent *event = [[GWTEvent alloc] init];
    event.name = @"House Partay!!!";
    event.location = @"Mi Casa";
    event.time = [[NSDate date] dateByAddingTimeInterval:120200];
    [self.eventsArray addObject:event];
    
    GWTEvent *event2 = [[GWTEvent alloc] init];
    event2.name = @"Study Group";
    event2.location = @"Lib West";
    event2.time = [[NSDate date] dateByAddingTimeInterval:100200];
    [self.eventsArray addObject:event2];
    
    GWTEvent *event3 = [[GWTEvent alloc] init];
    event3.name = @"Grilling";
    event3.location = @"Your house";
    event3.time = [[NSDate date] dateByAddingTimeInterval:600200];
    [self.eventsArray addObject:event3];
    
    GWTEvent *event4 = [[GWTEvent alloc] init];
    event4.name = @"Kappa Phi BBQ";
    event4.location = @"The House";
    event4.time = [[NSDate date] dateByAddingTimeInterval:800200];
    [self.eventsArray addObject:event4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
