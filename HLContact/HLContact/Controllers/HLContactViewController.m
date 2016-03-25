//
//  HLContactViewController.m
//  HLContact
//
//  Created by Horrace Lin on 16/2/22.
//  Copyright © 2016年 Horrace Lin. All rights reserved.
//

#import "HLContactViewController.h"
#import "HLContactEngine.h"
#import "HLContactDetailViewController.h"
@interface HLContactViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTB;
@property (nonatomic,strong) NSMutableArray * datas;
@end

@implementation HLContactViewController

- (NSMutableArray *) datas
{
    if (!_datas) {
        self.datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    HLContactEngine * engine = [[HLContactEngine alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.datas setArray:[engine loadPerson]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTB reloadData];
        });
    });
    
    
    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"txn";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    HLUser * user = [self.datas objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",user.userName,user.phones[[[user.phones allKeys] firstObject]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLContactDetailViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"detail"];
    HLUser * user = [self.datas objectAtIndex:indexPath.row];
    vc.myUser = user;
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end
