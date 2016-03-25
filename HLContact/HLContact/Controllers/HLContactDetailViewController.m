//
//  HLContactDetailViewController.m
//  HLContact
//
//  Created by administrater on 16/2/22.
//  Copyright © 2016年 administrater. All rights reserved.
//

#import "HLContactDetailViewController.h"
@interface HLContactDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray * datas;
@property (weak, nonatomic) IBOutlet UITableView *infoTB;
@end

@implementation HLContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _datas = [[NSMutableArray alloc] init];
    if (self.myUser.userName) {
        [_datas addObject:[NSString stringWithFormat:@"姓名&%@",self.myUser.userName]];
    }
    if (self.myUser.company) {
        [_datas addObject:[NSString stringWithFormat:@"公司&%@",self.myUser.company]];
    }
    
    for (NSString * key in self.myUser.phones.allKeys) {
        [_datas addObject:[NSString stringWithFormat:@"%@&%@",key,[self.myUser.phones objectForKey:key]]];
    }
    
    for (NSString * key in self.myUser.emails.allKeys) {
        [_datas addObject:[NSString stringWithFormat:@"%@&%@",key,[self.myUser.emails objectForKey:key]]];
    }
    
    for (NSString * key in self.myUser.ims.allKeys) {
        [_datas addObject:[NSString stringWithFormat:@"%@&%@",key,[self.myUser.ims objectForKey:key]]];
    }
    
    for (NSString * key in self.myUser.addresses.allKeys) {
        [_datas addObject:[NSString stringWithFormat:@"%@&%@",key,[self.myUser.addresses objectForKey:key]]];
    }
    
    for (NSString * key in self.myUser.relationships.allKeys) {
        [_datas addObject:[NSString stringWithFormat:@"%@&%@",key,[self.myUser.relationships objectForKey:key]]];
    }
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"txn";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView * sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }
    
    NSString * str = [_datas objectAtIndex:indexPath.row];
    NSString * key = [str componentsSeparatedByString:@"&"].firstObject;
    NSString * value = [str componentsSeparatedByString:@"&"].lastObject;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, cell.contentView.frame.size.height)];
    label.text = key;
    [cell.contentView addSubview:label];
    
    UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, cell.contentView.frame.size.width - 130 - 15, cell.contentView.frame.size.height)];
    label1.text = value;
    [cell.contentView addSubview:label1];
    return cell;
}


@end
