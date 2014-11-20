//
//  GWTContact.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/20/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTContact.h"

@implementation GWTContact

-(instancetype)initWithABContact:(ABAddressBookRef)ABContact {
    self = [super init];
    if (self) {
        [self loadProperties:ABContact];
    }
    return self;
}

-(void)loadProperties:(ABAddressBookRef)ABContact {
    CFTypeRef firstName;
    firstName = ABRecordCopyValue(ABContact, kABPersonFirstNameProperty);
    if (firstName) {
        self.firstName = (__bridge_transfer NSString*)firstName;
        CFRelease(firstName);
    }
    
    CFTypeRef lastName;
    lastName = ABRecordCopyValue(ABContact, kABPersonLastNameProperty);
    if (lastName) {
        self.lastName = (__bridge_transfer NSString*)lastName;
        CFRelease(lastName);
    }
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(ABContact, kABPersonPhoneProperty);
    NSInteger numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
    _listOfPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:numberOfPhoneNumbers];
    for (int i=0; i < numberOfPhoneNumbers; i++) {
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        
        [self.listOfPhoneNumbers addObject:(__bridge_transfer NSString *)currentPhoneValue];
        
        CFRelease(currentPhoneValue);
    }
    
    CFRelease(phoneNumbers);
}

-(NSString*)description {
    NSMutableString *contactDescription = [[NSMutableString alloc] initWithFormat:@"First Name: %@\nLast Name: %@\nPhone Numbers:\n", self.firstName, self.lastName];
    for (int i = 0; i < [self.listOfPhoneNumbers count]; i++) {
        [contactDescription appendFormat:@"%@\n", self.listOfPhoneNumbers[i]];
    }
    return contactDescription;
}

@end
