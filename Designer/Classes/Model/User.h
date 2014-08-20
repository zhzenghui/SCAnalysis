//
//  User.h
//  NetWork
//
//  Created by mbp  on 13-8-2.
//  Copyright (c) 2013年 zeng hui. All rights reserved.
//


#define Kuser_user_id @"user_id"
#define Kuser_name @"name"
#define Kuser_account @"account"
#define Kuser_dept_id @"dept_id"
#define Kuser_version @"version"


#import <Foundation/Foundation.h>

@interface User : NSObject



@property(nonatomic, retain) NSString *ID;
@property(nonatomic, retain) NSString *uuid;
@property(nonatomic, retain) NSString* SubCityCode;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *account;

@property(nonatomic, retain) NSString *Lat;
@property(nonatomic, retain) NSString *Lng;
@property(nonatomic, assign) bool isSignalIn;
@property(nonatomic, assign) bool isSignalOut;

@property(nonatomic, retain) NSString *currentConstruction;


@property(nonatomic, retain) NSString *phone;
@property(nonatomic, assign) NSInteger dept_id;
@property(nonatomic, retain) NSString *role;
@property(nonatomic, assign) long long version;
@property(nonatomic, retain) NSString *last_date;
@property(nonatomic, retain) NSString *created_at;
@property(nonatomic, retain) NSString *updated_at;
@property(nonatomic, retain) NSString *expiredDate;
@property(nonatomic, retain) NSString *accessToken;



+ (id)share;





@end
