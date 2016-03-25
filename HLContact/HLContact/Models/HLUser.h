//
//  HLUser.h
//  HLContact
//
//  Created by Horrace Lin on 16/3/26.
//  Copyright © 2016年 Horrace Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLUser : NSObject
@property (nonatomic,copy) NSString * contactId;
@property (nonatomic,copy) NSString * userName;
@property (nonatomic,copy) NSString * company;
@property (nonatomic,strong) NSMutableDictionary * phones;
@property (nonatomic,strong) NSMutableDictionary * emails;
@property (nonatomic,strong) NSMutableDictionary * ims;
@property (nonatomic,strong) NSMutableDictionary * addresses;
@property (nonatomic,strong) NSMutableDictionary * relationships;
@end
