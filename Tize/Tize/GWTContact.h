//
//  GWTContact.h
//  Tize
//
//  Created by Joseph Pecoraro on 11/20/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

@import Foundation;
@import AddressBook;

@interface GWTContact : NSObject

@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, strong) NSMutableArray *listOfPhoneNumbers;

-(instancetype)initWithABContact:(ABAddressBookRef)ABContact;

@end
