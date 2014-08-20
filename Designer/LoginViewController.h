//
//  LoginViewController.h
//  OrientParkson
//
//  Created by i-Bejoy on 13-12-23.
//  Copyright (c) 2013年 zeng hui. All rights reserved.
//

#import "BaseViewController.h"
#import "ZHPassDataJSON.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"



@interface LoginViewController : UIViewController<UITextFieldDelegate, DownloaderDelegate, ZHPassDataJSONDelegate>
{
    UITextField *nameTextField;
    UITextField *passwordTextField;
    
    UIView *loginBackGroundView;
    NSMutableArray *picArray;

}

@property(nonatomic, assign) id delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIView *v1;
@property (strong, nonatomic) IBOutlet UIView *v2;
@property (strong, nonatomic) IBOutlet UIView *v3;

@property (nonatomic, strong) PendingOperations *pendingOperations;

@property (weak, nonatomic) IBOutlet UITextField *oldPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *user_name;



- (IBAction)xiugaiSender:(id)sender;
- (IBAction)wangjiSender:(id)sender;
- (IBAction)backTop:(id)sender;

@end
