//
//  GWTEditEventViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEditEventViewController.h"
#import "GWTEventsViewController.h"

@interface GWTEditEventViewController ()

@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;

@end

@implementation GWTEditEventViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        //if we use regular init we are creating an event, not editing
    }
    return self;
}

-(instancetype)initWithEvent:(GWTEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateFields];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:leftSwipe];
}

-(void)updateFields {
    [self.eventNameTextField setText:[self.event eventName]];
}

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
