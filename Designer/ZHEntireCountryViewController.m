//
//  ZHEntireCountryViewController.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-6.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHEntireCountryViewController.h"
#import "ZHMapViewController.h"


@interface ZHEntireCountryViewController ()

@end

@implementation ZHEntireCountryViewController

- (void)back:(UIButton *)button
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadConstructionsData" object:nil];
    
    [UIView animateWithDuration:KDuration animations:^{
        self.view.frame = CGRectMake(1024, 0, 1024, 768);
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


-(void)openMap:(NSString *)string
{
    
    ZHMapViewController *map = [[ZHMapViewController alloc] initWithNibName:@"ZHMapViewController" bundle:nil];
    map.view.frame = CGRectMake(1024, 0, 1024, 768);
    map.city_code = string;
    
    [self.view addSubview:map.view];
    [self addChildViewController:map];
    
    
    [UIView animateWithDuration:KDuration animations:^{
        
        self.baseView.frame = CGRectMake(-1024, 0, 1024, 768);
        map.view.frame = CGRectMake(0, 0, 1024, 768);
        
    }];
    
}

-(void)reloadMapData
{
    
    [UIView animateWithDuration:KDuration animations:^{
        
        self.baseView.frame = CGRectMake(0, 0, 1024, 768);
        
    }];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.baseView addSubview:self.bView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMapData) name:@"reloadMapData" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToMain:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadConstructionsData" object:nil];
    
    [UIView animateWithDuration:KDuration animations:^{
        self.view.frame = CGRectMake(1024, 0, 1024, 768);
    }]; 
}

- (IBAction)openCityMap:(UIButton *)sender {
    
    [self openMap:[NSString stringWithFormat:@"%d", sender.tag]];
    
}
@end
