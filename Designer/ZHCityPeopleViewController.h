//
//  ZHBehaviorViewController.h
//  SC_Analysis
//
//  Created by bejoy on 14-6-5.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "BaseViewController.h"
#import "DateTimePopoverController.h"
#import "PdfPopoverController.h"



@interface ZHCityPeopleViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, DateTimePopoverDelegate, PdfPopoverDelegate>
{
    NSMutableArray *usersArray;
    NSMutableArray *citysArray;

    
    UIButton *currentButton;

    int currentType;
    
    
    
    UIButton *cityButton;
    UIButton *dateButton;
    UIButton *peopleButton;
    UIButton *seachButton;
    
}
@property (nonatomic, strong) UIPopoverController *popover;

@end
