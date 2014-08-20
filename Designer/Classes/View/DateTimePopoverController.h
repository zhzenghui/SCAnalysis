//
//  DateTimePopoverController.h
//  SC_Analysis
//
//  Created by bejoy on 14-6-12.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "BaseViewController.h"


@protocol DateTimePopoverDelegate <NSObject>

- (void)selectDatePopover:(NSDate *)date;

@end


@interface DateTimePopoverController : UIViewController

@property(nonatomic, retain)    id<DateTimePopoverDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;



@property(nonatomic, strong) UIViewController *viewController;
@property(nonatomic, strong) UIPopoverController *popController;
- (IBAction)select:(id)sender;
@end
