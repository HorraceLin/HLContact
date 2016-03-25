//
//  HLContact.h
//  HLContact
//
//  Created by Horrace Lin on 16/2/18.
//  Copyright © 2016年 Horrace Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONTACT_ID @"CONTACT_ID"

@interface HLContact : NSObject
@property (nonatomic,copy) NSString * firstName;
@property (nonatomic,copy) NSString * lastName;
@property (nonatomic,copy) NSString * middlename;
@property (nonatomic,copy) NSString * prefix;
@property (nonatomic,copy) NSString * suffix;
@property (nonatomic,copy) NSString * nickname;
@property (nonatomic,copy) NSString * firstnamePhonetic;
@property (nonatomic,copy) NSString * lastnamePhonetic;
@property (nonatomic,copy) NSString * middlenamePhonetic;
@property (nonatomic,copy) NSString * organization;

@property (nonatomic,copy) NSString * jobtitle;
@property (nonatomic,copy) NSString * department;
@property (nonatomic,strong) NSDate * birthday;
@property (nonatomic,copy) NSString * note;
@property (nonatomic,copy) NSString * firstknow;
@property (nonatomic,copy) NSString * lastknow;

@property (nonatomic,strong) NSMutableDictionary * emailValue;
@property (nonatomic,strong) NSMutableDictionary * addressValue;
@property (nonatomic,strong) NSMutableDictionary * dateValue;
@property (nonatomic,strong) NSMutableDictionary * imValue;
@property (nonatomic,strong) NSMutableDictionary * phone;
@property (nonatomic,strong) NSMutableDictionary * url;
@property (nonatomic,strong) NSMutableDictionary * relationships;
@property (nonatomic,strong) NSData * imageData;
@end
