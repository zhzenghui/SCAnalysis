//
//  DateTimePopoverController.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-12.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "DateTimePopoverController.h"

@interface DateTimePopoverController ()

@end

@implementation DateTimePopoverController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self. datePicker.date = [NSDate date];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.contentSizeForViewInPopover = CGSizeMake(300, 320);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)select:(id)sender {
    
    [self.popController dismissPopoverAnimated:YES];
    
    
    
    if ([_delegate respondsToSelector:@selector(selectDatePopover:)]) {
        [_delegate selectDatePopover:self.datePicker.date];
    }
    
}
@end
