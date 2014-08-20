//
//  ZHBehaviorViewController.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-5.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHJunGongViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "XMLReader.h"



@interface ZHJunGongViewController ()
{
    UITableView *tb;

}
@end

@implementation ZHJunGongViewController



- (void)loadConstructionsData
{
    
    
    [self.dataMArray removeAllObjects];
    
    
    
    
    [SVProgressHUD showWithStatus:@"正在刷新数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/JunGongTongJi", KHomeUrl];
    NSDictionary *parameters = @{ @"subCityCode":  SharedAppUser.SubCityCode };
    
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        
        
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        dict = dict[@"ArrayOfJunGong"][@"JunGong"];
        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            
            self.dataMArray = [[NSMutableArray alloc] init];
            
            return ;
        }
        else {
            [SVProgressHUD dismiss];
            
            
            
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                [self.dataMArray addObject:  dict];
            }
            else {
                self.dataMArray =  dict;
            }
            
        }
        
        
        [tb reloadData];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    tb = [[UITableView alloc] initWithFrame:RectMake2x(0 , 0, 1888, 1260) style:UITableViewStylePlain];
    tb.backgroundColor = [UIColor clearColor];
    tb.dataSource = self;
    tb.delegate = self;
    
    [self.view addSubview:tb];

    
    
    self.dataMArray = [[NSMutableArray alloc] init];
    [self loadConstructionsData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    

    return self.dataMArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    return 56;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 60;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 1888/2, 60);
    headerView.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"竣工统计-表格title"]];
    return headerView;
    
}



- (UITableViewCell *)cell3Height
{
    
    static NSString *CellIdentifier = @"Cell3h";
    
    UITableViewCell *cell = [tb dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    for (int i = 1; i < 7 ; i++) {
        
        UILabel *l = [[UILabel alloc] init];
        l.textAlignment = NSTextAlignmentCenter;
        l.tag = i +100;
        
        if ( i  ==1) {
            l.frame = RectMake2x( 0, 0, 314, 120);
            l.numberOfLines = 0;
        }
        if (i == 2) {
            l.frame = RectMake2x( 315, 0, 523, 120);
        }
        
        if (i == 3) {
            l.frame = RectMake2x( 839, 0, 524, 120);
        }
        
        if (i == 4) {
            l.frame = RectMake2x( 1364, 0, 524, 120);
        }
        
        [cell.contentView addSubview:l];
    }
    

    return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    
    static NSString *CellIdentifier = @"Cell3h";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [self cell3Height];
    }
    
    
    
    
    NSDictionary *dict = [self.dataMArray objectAtIndex:indexPath.row];
    
    
    
    
    UILabel *l1 = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *l2 = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *l3 = (UILabel *)[cell.contentView viewWithTag:103];
    UILabel *l4 = (UILabel *)[cell.contentView viewWithTag:104];
    UILabel *l5 = (UILabel *)[cell.contentView viewWithTag:105];
    UILabel *l6 = (UILabel *)[cell.contentView viewWithTag:106];
    
    
    
    l1.text = @"";
    l2.text = @"";
    l3.text = @"";
    l4.text = @"";
    l5.text = @"";
    l6.text = @"";
    
    
    l1.text = dict [@"SubCityName"][@"text"];
    l2.text = dict [@"PingJunGongQi"][@"text"];
    l3.text = dict [@"AnShiJunGongLv"][@"text"];
    l4.text = dict [@"WeiKuanJiShiLv"][@"text"];


    return cell;
    
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}




@end
