//
//  GWTTizeSearchTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 7/13/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeSearchTableViewController.h"

@interface GWTTizeSearchTableViewController () <UISearchBarDelegate>

// @property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL shouldChangeTextCalled;
@property (nonatomic, assign) BOOL textCleared;

@end

@implementation GWTTizeSearchTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSearching = NO;
    self.shouldChangeTextCalled = NO;
    self.textCleared = NO;
    
    [self setupSearchController];
}

-(void)setupSearchController {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.translucent = YES;
    self.searchBar.backgroundColor = kOffWhiteColor;
    
    self.searchBar.delegate = self;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kGreenColor, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    [super addSearchBarToTableView:self.searchBar];
    
    /* UISearchController Implementation that doesn't quite work (it tries to hide the nave bar!)
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, CGRectGetWidth(self.searchController.searchBar.frame), 44);
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.translucent = YES;
    self.searchController.searchBar.backgroundColor = kOffWhiteColor;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kGreenColor, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    [super addSearchBarToTableView:self.searchController.searchBar];
    
    self.definesPresentationContext = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
     */
}

#pragma mark - Search Bar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.textCleared) {
        return;
    }
    
    //Clear Button Clicked
    if (!self.shouldChangeTextCalled) {
        self.isSearching = NO;
        self.textCleared = YES;
        
        [self.view endEditing:YES];
        return;
    }
    
    //Update search text
    [self updateSearchResultsWithString:searchText];
    self.shouldChangeTextCalled = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    [self.view endEditing:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"SHOULDBEGIN");
    if (self.textCleared || ((![self.searchBar isFirstResponder] && self.searchBar.text.length == 0) && self.isSearching)) {
        self.textCleared = NO;
        self.isSearching = NO;
        
        [self.tableView reloadData];
        return NO;
    }

    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"BEGINEDITING");
    self.isSearching = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"ENDEDITING");
    [self.searchBar resignFirstResponder];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"SHOULDCHANGETEXT");
    self.shouldChangeTextCalled = YES;
    return YES;
}

#pragma mark - Searching

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self updateFilteredListsWithString:searchString];
    [self.tableView reloadData];
}

-(void)updateSearchResultsWithString:(NSString*)string {
    [self updateFilteredListsWithString:string];
    [self.tableView reloadData];
}

-(BOOL)searchIsActive {
    return self.searchBar.isFirstResponder;
    // return self.searchController.isActive;
}

-(void)updateFilteredListsWithString:(NSString *)searchString {
    [NSException raise:@"Not Implemented" format:@"Please implement this method in a subclass"];
}

@end
