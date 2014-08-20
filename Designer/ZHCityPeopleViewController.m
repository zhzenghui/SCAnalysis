//
//  ZHBehaviorViewController.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-5.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHCityPeopleViewController.h"
#import "ZHPeopleViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "XMLReader.h"


@interface ZHCityPeopleViewController ()
{
    UITableView *tb;

}
@end

@implementation ZHCityPeopleViewController


- (NSMutableArray *)arrayFor :(NSMutableArray *)array
{
    
    if ( ! usersArray) {
        
        usersArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [usersArray addObject: dict[@"text"]];
        }
        return usersArray;
    }
    
    return nil;
    
}

- (void)loadUserList
{
    
    
    [SVProgressHUD showWithStatus:@"正在刷新数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    __block NSMutableArray *a = [NSMutableArray array];
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/GetAllMonitor", KHomeUrl];
    NSDictionary *parameters = @{ @"subCityCode":  SharedAppUser.SubCityCode};
    
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        dict = dict[@"ArrayOfString"][@"string"];
        
        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            a = [[NSMutableArray alloc] init];
            return ;
        }
        else {
            [SVProgressHUD dismiss];
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                [a addObject:  dict];
            }
            else {
                a =  dict;
            }
        }
        
        [self arrayFor:a];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    
}

- (void)loadConstructionsData
{
    
    
    [self.dataMArray removeAllObjects];
    
    
    NSString *name = [NSString stringWithFormat:@""];
    if ([peopleButton.titleLabel.text isEqualToString:@"所有人"]) {
        name = @"";
    }
    else {
        
        
        if (peopleButton.titleLabel.text) {
            
            name = peopleButton.titleLabel.text;
        }else {
            name = @"";
        }
        
    }
    

    
    NSString *queryDate = [NSString stringWithFormat:@""];
    if ([dateButton.titleLabel.text isEqualToString:@"所有人"]) {
        queryDate = @"";
    }
    else
        queryDate = dateButton.titleLabel.text;
    
    
    
    [SVProgressHUD showWithStatus:@"正在刷新数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    NSDictionary *parameters = @{ @"subCityCode":  SharedAppUser.SubCityCode,
                                  @"name": name,
                                  @"queryDate": queryDate};
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/GetUserBehavior", KHomeUrl];
    
    
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        
        
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        dict = dict[@"ArrayOfUserBehavior"][@"UserBehavior"];
        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            
            self.dataMArray = [[NSMutableArray alloc] init];
            [tb reloadData];
            
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
            
            

            [tb reloadData];
        }
        
        
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

- (void)control:(UIButton *)button
{
    
    
    currentButton = button;
    
    
    switch (button.tag) {
        case 1000:
        {
            break;
        }
        case 1001:  //日期
        {
            
            [self openMapDatePiker:button];
            break;
        }
        case 1002:
        {
            [self openUserListPopover:button];
            break;
        }
        case 1003: //
        {
            
            [self loadConstructionsData];
            break;
        }
        case 1004: //
        {
            
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            
            break;
        }
            
        default:
            break;
    }
}










- (void)loadView
{
    [super loadView];
    self.dataMArray =[[NSMutableArray alloc] init];

    
    [[ImageView share] addToView:self.view imagePathName:@"表格-城市" rect:RectMake2x(40, 80, 1130, 120)];
    
//   cityButton =[[Button share] addToView:self.view addTarget:self rect:RectMake2x(40, 80, 1130, 120) tag:1000 action:@selector(control:) imagePath:@"表格-城市"
//         highlightedImagePath:@"表格-城市"
//                
//            SelectedImagePath:@"表格-城市"];
    cityButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cityButton addTarget:self action:@selector(control:) forControlEvents:UIControlEventTouchUpInside];
    
    cityButton.frame = RectMake2x(40, 80, 340, 120);
    [self.view addSubview:cityButton];
    

    
    
    
    
    [[ImageView share] addToView:self.view imagePathName:@"表格-时间" rect:RectMake2x(290, 80, 340, 120)];
    dateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dateButton addTarget:self action:@selector(control:) forControlEvents:UIControlEventTouchUpInside];
    
    dateButton.frame = RectMake2x(290, 80, 340, 120);
    dateButton.tag = 1001;
    [self.view addSubview:dateButton];
    [dateButton setTitle:[NSDate stringFromDate:[NSDate date] withFormat:@"YYYY-MM-dd" ] forState:UIControlStateNormal];
    
    
//
//    peopleButton = [[Button share] addToView:self.view addTarget:self rect:RectMake2x(670, 80, 340, 120) tag:1002 action:@selector(control:) imagePath:@"表格-姓名"
//         highlightedImagePath:@"表格-姓名"
//            SelectedImagePath:@"表格-姓名"
//     ];
    
    [[ImageView share] addToView:self.view imagePathName:@"表格-姓名" rect:RectMake2x(670, 80, 340, 120) ];
    peopleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [peopleButton addTarget:self action:@selector(control:) forControlEvents:UIControlEventTouchUpInside];
    peopleButton.tag = 1002;
    peopleButton.frame = RectMake2x(670, 80, 340, 120);
    [self.view addSubview:peopleButton];
    
    
    
    
    seachButton =  [[Button share] addToView:self.view addTarget:self rect:RectMake2x(1050, 80, 340, 120) tag:1003 action:@selector(control:) imagePath:@"表格-搜索"
         highlightedImagePath:@"表格-搜索"
            SelectedImagePath:@"表格-搜索"
     ];
    
    
//    [[ImageView share] addToView:self.view imagePathName:@"表格-姓名" rect:RectMake2x(670, 80, 340, 120) ];
//    peopleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [peopleButton addTarget:self action:@selector(control:) forControlEvents:UIControlEventTouchUpInside];
//    
//    peopleButton.frame = RectMake2x(290, 80, 340, 120);
//    [self.view addSubview:peopleButton];
    
    
    
    
    
    [[Button share] addToView:self.view addTarget:self rect:RectMake2x(1645, 80, 120, 120) tag:1003 action:@selector(control:)
                    imagePath:@"按钮-刷新"];
    [[Button share] addToView:self.view addTarget:self rect:RectMake2x(1805, 80, 120, 120) tag:1004 action:@selector(control:)
                    imagePath:@"按钮-返回"
     ];
    
    
    
    tb = [[UITableView alloc] initWithFrame:RectMake2x(40 , 236, 1888, 1260) style:UITableViewStylePlain];
    tb.backgroundColor = [UIColor clearColor];
    
    tb.dataSource = self;
    tb.delegate = self;
    
    [self.view addSubview:tb];

    
    
    [self loadConstructionsData];
}


-  (void)selectDatePopover:(NSDate *)date
{
    NSString *s = [NSDate stringFromDate:date withFormat:@"YYYY-MM-dd"];
    [_popover dismissPopoverAnimated:YES];

    [dateButton setTitle:s forState:UIControlStateNormal];
    
   
}

- (void)selectPopover:(NSIndexPath *)index
{
    [_popover dismissPopoverAnimated:YES];
    
    
    
    NSString *name =  usersArray[index.row];
    
    [currentButton setTitle:name forState:UIControlStateNormal];
    
    NSString *date = currentButton.titleLabel.text;
    
    [self loadConstructionsData];
    
    
}

- (IBAction)openMapDatePiker:(id)sender {
    
    
    currentButton = (UIButton *)sender;
    
    UIButton *b = (UIButton *)sender;
    DateTimePopoverController *pdfVC = [[DateTimePopoverController alloc] init];
    pdfVC.delegate = self;

    
    _popover = [[UIPopoverController alloc] initWithContentViewController:pdfVC];
    
    [_popover presentPopoverFromRect:b.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}



- (IBAction)openUserListPopover:(id)sender {
    
    
    currentButton = (UIButton *)sender;
    
    
    UIButton *b = (UIButton *)sender;
    PdfPopoverController *pdfVC = [[PdfPopoverController alloc] init];
    pdfVC.delegate = self;
    pdfVC.fileArrayM = usersArray;
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:pdfVC];
    [_popover presentPopoverFromRect:b.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [cityButton setTitle:self.dataMDict[@"SubCityName"][@"text"]forState:UIControlStateNormal];
// cp.dataMDict
    
    [peopleButton setTitle:@"所有人" forState:UIControlStateNormal];
    
    [self loadUserList];
    
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
    headerView.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"行为统计-表格title-01"]];
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
            l.frame = RectMake2x( 315, 0, 314, 120);
        }
        
        if (i == 3) {
            l.frame = RectMake2x( 630, 0, 314, 120);
        }
        
        if (i == 4) {
            l.frame = RectMake2x( 945, 0, 314, 120);
        }
        if (i == 5) {
            l.frame = RectMake2x( 1359, 0, 314, 120);
        }
        
        if (i == 6) {
            l.frame = RectMake2x( 1574, 0, 314, 120);
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
    
    
    l1.text = dict [@"Name"][@"text"];
    l2.text = dict [@"JieDanLiang"][@"text"];
    l3.text = dict [@"ChuQinLv"][@"text"];
    l4.text = dict [@"HeGeLv"][@"text"];
    l5.text = dict [@"ChuQinCiShu"][@"text"];
    l6.text = dict [@"ZhuChangShiJian"][@"text"];
    
    

    return cell;
    
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

//    ZHPeopleViewController *people = [[ZHPeopleViewController alloc] init];
//    
//    [self presentViewController:people animated:YES completion:^{
//        
//    }];
}




@end
