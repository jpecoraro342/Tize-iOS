//
//  GWTNetworking.h
//  Tize
//
//  Created by Joseph Pecoraro on 2/17/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

@protocol GWTNetworking

///--------------------------------------
/// @name Blocks
///--------------------------------------

typedef void (^GWTBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^GWTIntegerResultBlock)(int number, NSError *error);
typedef void (^GWTArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^PFObjectResultBlock)(NSObject *object,  NSError *error);
typedef void (^GWTSetResultBlock)(NSSet *channels, NSError *error);
// typedef void (^GWTUserResultBlock)(GWTUser *user, NSError *error);
typedef void (^GWTDataResultBlock)(NSData *data, NSError *error);
typedef void (^GWTDataStreamResultBlock)(NSInputStream *stream, NSError *error);
typedef void (^GWTFilePathResultBlock)(NSString *filePath, NSError *error);
typedef void (^GWTStringResultBlock)(NSString *string, NSError *error);
typedef void (^GWTIdResultBlock)(id object, NSError *error);

@required

#pragma mark - Get

#pragma mark - Create

-(void)createFollowingEventForUser:(NSString*)followerUserId followingUser:(NSString*)userId completionBlock:(GWTBooleanResultBlock)completionBlock;


@optional


@end
