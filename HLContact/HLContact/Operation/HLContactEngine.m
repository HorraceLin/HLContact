//
//  HLContactEngine.m
//  HLContact
//
//  Created by Horrace Lin on 16/3/25.
//  Copyright © 2016年 Horrace Lin. All rights reserved.
//

#import "HLContactEngine.h"
#import "HLContact.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "HLContactDetailViewController.h"
@implementation HLContactEngine

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (NSArray *) loadPerson
{
    NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    
    if (__CURRENT__DEVICE__VERSION >= 9.0) {
        CNContactFormatter  * formatter = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
        
        NSArray * keysFetch = @[formatter,CNContactEmailAddressesKey,CNContactPhoneNumbersKey,CNContactImageDataAvailableKey,CNContactThumbnailImageDataKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey,CNContactPostalAddressesKey];
        
        CNContactStore * store = [[CNContactStore alloc] init];
        NSArray * allContainers = [store containersMatchingPredicate:nil error:nil];
        
        NSMutableArray * datas = [[NSMutableArray alloc] init];
        for (CNContainer * container in allContainers) {
            NSPredicate * pre = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
            NSArray * res = [store unifiedContactsMatchingPredicate:pre keysToFetch:keysFetch error:nil];
            
            [datas addObjectsFromArray:res];
        }
        
        [resultArray setArray:[self transferFromCNLibrary:datas]];
    }
    else
    {
        //含警告的代码,如下,btn为UIButton类型的指针
        ABAddressBookRef ref = ABAddressBookCreateWithOptions(NULL, NULL);
        
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(ref, ^(bool granted, CFErrorRef error) {
                CFErrorRef * error1 = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
                [resultArray setArray:[self copyAddressBook:addressBook]];
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
            
            CFErrorRef *error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
            [resultArray setArray:[self copyAddressBook:addressBook]];
        }
        
        
    }
    return resultArray;
}

- (NSArray *)transferFromCNLibrary:(NSArray *) cnLibrary
{
    NSMutableArray * users = [[NSMutableArray alloc] init];
    for (CNContact * contact in cnLibrary) {
        HLUser  * user = [[HLUser alloc] init];
        user.emails   = [[NSMutableDictionary alloc] init];
        user.addresses = [[NSMutableDictionary alloc] init];
        user.ims      = [[NSMutableDictionary alloc] init];
        user.phones        = [[NSMutableDictionary alloc] init];
        user.relationships = [[NSMutableDictionary alloc] init];
        
        NSMutableString * fullName = [[NSMutableString alloc] initWithString:contact.givenName];
        [fullName appendString:[self isEmpty:contact.middleName]?@"":[NSString stringWithFormat:@" %@",contact.middleName]];
        [fullName appendString:[self isEmpty:contact.familyName]?@"":[NSString stringWithFormat:@" %@",contact.familyName]];
        
        user.userName = fullName;
        user.company = contact.organizationName;
        
        
        for (CNLabeledValue * phone in contact.phoneNumbers) {
            CNPhoneNumber * phoneNumber = phone.value;
            [user.phones setObject:phoneNumber.stringValue forKey:phone.label];
        }
        
        for (CNLabeledValue * email in contact.emailAddresses) {
            [user.emails setObject:email.value forKey:email.label];
        }
        
        for (CNLabeledValue * imt in contact.instantMessageAddresses) {
            [user.ims setObject:imt.value forKey:imt.label];
        }
        
        for (CNLabeledValue * address in contact.postalAddresses) {
            CNPostalAddress * postalAddress = address.value;
            NSString * str = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",postalAddress.country?postalAddress.country:@"",postalAddress.city?postalAddress.city:@"",postalAddress.state?postalAddress.state:@"",postalAddress.street?postalAddress.street:@"",postalAddress.postalCode?postalAddress.postalCode:@"",postalAddress.ISOCountryCode?postalAddress.ISOCountryCode:@""];
            [user.addresses setObject:str forKey:address.label];
        }
        
        for (CNLabeledValue * relations in contact.contactRelations) {
            [user.relationships setObject:relations.value forKey:relations.label];
        }
        
        [users addObject:user];
    }
    return users;
}

- (NSArray *)copyAddressBook:(ABAddressBookRef)addressBook
{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray * datas = [[NSMutableArray alloc] init];
    for ( int i = 0; i < numberOfPeople; i++){
        HLContact * contact = [[HLContact alloc] init];
        contact.emailValue   = [[NSMutableDictionary alloc] init];
        contact.addressValue = [[NSMutableDictionary alloc] init];
        contact.dateValue    = [[NSMutableDictionary alloc] init];
        contact.imValue      = [[NSMutableDictionary alloc] init];
        contact.phone        = [[NSMutableDictionary alloc] init];
        contact.url          = [[NSMutableDictionary alloc] init];
        contact.relationships = [[NSMutableDictionary alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        contact.firstName = firstName;
        contact.lastName  = lastName;
        //读取middlename
        NSString *middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        
        contact.middlename = middlename;
        //读取prefix前缀
        NSString *prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
        //读取suffix后缀
        NSString *suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
        //读取nickname呢称
        NSString *nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
        
        contact.prefix = prefix;
        contact.suffix = suffix;
        contact.nickname = nickname;
        
        //读取firstname拼音音标
        NSString *firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
        //读取lastname拼音音标
        NSString *lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
        //读取middlename拼音音标
        NSString *middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
        
        contact.firstnamePhonetic = firstnamePhonetic;
        contact.lastnamePhonetic  = lastnamePhonetic;
        contact.middlenamePhonetic = middlenamePhonetic;
        
        //读取organization公司
        NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        //读取jobtitle工作
        NSString *jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
        //读取department部门
        NSString *department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
        //读取birthday生日
        NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        //读取note备忘录
        NSString *note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
        
        contact.organization = organization;
        contact.jobtitle = jobtitle;
        contact.department = department;
        contact.birthday = birthday;
        contact.note = note;
        //第一次添加该条记录的时间
        NSString *firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        NSLog(@"第一次添加该条记录的时间%@\n",firstknow);
        //最后一次修改該条记录的时间
        NSString *lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
        NSLog(@"最后一次修改該条记录的时间%@\n",lastknow);
        
        contact.firstknow = firstknow;
        contact.lastknow = lastknow;
        
        
        
        //获取email多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        int emailcount = ABMultiValueGetCount(email);
        for (int x = 0; x < emailcount; x++)
        {
            //获取email Label
            NSString* emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
            //获取email值
            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
            if (emailContent) {
                [contact.emailValue setObject:emailContent forKey:emailLabel];
            }
            
        }
        //读取地址多值
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        int count = ABMultiValueGetCount(address);
        
        for(int j = 0; j < count; j++)
        {
            //获取地址Label
            NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
            //获取該label下的地址6属性
            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
            NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
            
            NSString * str = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",country?country:@"",city?city:@"",state?state:@"",street?street:@"",zip?zip:@"",coutntrycode?coutntrycode:@""];
            [contact.addressValue setValue:str forKey:addressLabel];
        }
        
        //获取dates多值
        ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
        int datescount = ABMultiValueGetCount(dates);
        for (int y = 0; y < datescount; y++)
        {
            //获取dates Label
            NSString* datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
            //获取dates值
            NSString* datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(dates, y);
            
            if (datesContent) {
                [contact.dateValue setValue:datesContent forKey:datesLabel];
            }
            
        }
        //获取kind值
        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
        if (recordType == kABPersonKindOrganization) {
            // it's a company
            NSLog(@"it's a company\n");
        } else {
            // it's a person, resource, or room
            NSLog(@"it's a person, resource, or room\n");
        }
        
        
        //获取IM多值
        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            //获取IM Label
            NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            NSString* username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            
            NSString * str = [NSString stringWithFormat:@"%@:%@",username,service];
            [contact.imValue setValue:str forKey:instantMessageLabel];
        }
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            //获取該Label下的电话值
            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            if (personPhone) {
                [contact.phone setValue:personPhone forKey:personPhoneLabel];
            }
            
        }
        
        //获取URL多值
        ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        {
            //获取电话Label
            NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
            //获取該Label下的电话值
            NSString * urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
            
            if (urlContent) {
                [contact.url setValue:urlContent forKey:urlLabel];
            }
            
        }
        
        ABMutableMultiValueRef relate = ABRecordCopyValue(person, kABPersonRelatedNamesProperty);
        
        for (int m = 0; m < ABMultiValueGetCount(relate); m++) {
            NSString * relateLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(relate, m));
            //获取該Label下的电话值
            NSString * relateContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(relate,m);
            [contact.relationships setValue:relateContent forKey:relateLabel];
        }
        //读取照片
        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);
        contact.imageData = image;
        
        
        NSUserDefaults * config = [NSUserDefaults standardUserDefaults];
        if (![config objectForKey:CONTACT_ID] || [[config objectForKey:CONTACT_ID] isEqualToString:@""]) {
            CFUUIDRef puuid = CFUUIDCreate( nil );
            CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
            NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
            CFRelease(puuid);
            CFRelease(uuidString);
            result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            [config setObject:result forKey:CONTACT_ID];
        }
        
        
        HLUser * user = [[HLUser alloc] init];
        user.userName = [[contact.firstName?contact.firstName:@"" stringByAppendingString:contact.middlename?contact.middlename:@""] stringByAppendingString:contact.lastName?contact.lastName:@""];
        user.contactId = [config objectForKey:CONTACT_ID];
        user.company = contact.organization;
        user.phones = contact.phone;
        user.emails = contact.emailValue;
        user.ims = contact.imValue;
        user.addresses = contact.addressValue;
        user.relationships = contact.relationships;
        
        [datas addObject:user];
    }
    return datas;
    //[self dataProcessTemp];
}

/*
- (void) dataProcessTemp
{
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"userName=%@",@"测试1"];
    NSArray * result = [self.datas filteredArrayUsingPredicate:pre];
    [self.datas removeAllObjects];
    
    if (result.count > 0) {
        HLUser * user = result[0];
        for (int i = 0; i < 100; i ++) {
            HLUser * myUser = [[HLUser alloc] init];
            myUser.userName = [NSString stringWithFormat:@"测试%d",i+1];
            myUser.contactId = user.contactId;
            myUser.company = user.company;
            myUser.phones = user.phones;
            myUser.emails = user.emails;
            myUser.ims = user.ims;
            myUser.addresses = user.addresses;
            myUser.relationships = user.relationships;
            [self.datas addObject:myUser];
        }
    }
}
*/

- (BOOL) isEmpty:(NSString *) originString
{
    return !(originString&&![originString isEqualToString:@""]);
}
#pragma clang diagnostic pop
@end
