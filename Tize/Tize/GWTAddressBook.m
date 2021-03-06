//
//  GWTAddressBook.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/20/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTAddressBook.h"
#import "GWTContact.h"

@import AddressBook;

@implementation GWTAddressBook {
    ABAddressBookRef _addressBook;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        [self checkAccess];
    }
    return self;
}

-(void)checkAccess {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        NSLog(@"Denied");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        NSLog(@"Authorized");
        [self requestAccess];
    }
    else { //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        NSLog(@"Not determined");
        [self requestAccess];
    }
}

-(void)requestAccess {
    _addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted){
            NSLog(@"Just denied");
            return;
        }
        else {
            NSLog(@"Just authorized");
            [self loadContacts];
        }
    });
}

-(void)loadContacts {
    NSArray *contacts = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(_addressBook));
    
    _listOfContacts = [[NSMutableArray alloc] init];
    for (int i = 0; i < [contacts count]; i++) {
        ABRecordRef record = (ABRecordRef)CFBridgingRetain([contacts objectAtIndex:i]);
        GWTContact *contact = [[GWTContact alloc] initWithABContact:record];
        if (contact.firstName || contact.lastName) {
            [self.listOfContacts addObject:contact];
        }
    }
    
    [self.listOfContacts sortUsingComparator:^NSComparisonResult(GWTContact* contact1, GWTContact* contact2) {
        return [contact1.firstName ?: contact1.lastName compare:contact2.firstName ?: contact2.lastName];
    }];
}

@end
