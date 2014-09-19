//
//  LoginViewController.m
//  OrientParkson
//
//  Created by i-Bejoy on 13-12-23.
//  Copyright (c) 2013年 zeng hui. All rights reserved.
//

#import "LoginViewController.h"
#import "NetWork.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "OpenUDID.h"
#import <AdSupport/AdSupport.h>
#import "XMLReader.h"


@interface LoginViewController ()
{
    NSMutableData *data;

}
@end

@implementation LoginViewController

- (void)closeMe
{
    nameTextField.text = @"";
    passwordTextField.text = @"";
    
    
    
    [UIView animateWithDuration:1 animations:^{
        self.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_GetUserProfileSuccess" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadConstructionsData" object:nil];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadNetData" object:nil];

            
            
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [SVProgressHUD dismiss];
            
        }
    }];

}

- (void)getPic:(NSDictionary *)dict
{
    
    
}


- (IBAction)xiugaiSender:(id)sender {
    
    [self.contentScrollView scrollRectToVisible:CGRectMake(0, 1537/2, 810/2, 1537/2) animated:YES];

    
    self.v2 .alpha = 0;
    self.v3 .alpha = 1;
}

- (IBAction)wangjiSender:(id)sender {
    
    
    [self.contentScrollView scrollRectToVisible:CGRectMake(0, 1537/2, 810/2, 1537/2) animated:YES];

    
    self.v2 .alpha = 1;
    self.v3 .alpha = 0;
}

- (IBAction)backTop:(id)sender {
    [self.contentScrollView scrollRectToVisible:CGRectMake(0, 0, 810/2, 1537/2) animated:YES];

}


#pragma mark - update

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
}

// 3. 每一次下载完成一个进行回调

- (void)downloaderDidFinish:(ImageDownloader *)downloader
{

    
    [self.pendingOperations.downloadsInProgress removeObjectForKey: [downloader.dict objectForKey:@"url"]];
    
    int xiazaishuliang = [picArray count] - [self.pendingOperations.downloadsInProgress count];
    
    
    
    
    NSString *s = [NSString stringWithFormat:@"已下载%d个， 共%d个  \n\n请保持屏幕为常亮状态",  xiazaishuliang, [picArray count]];
    [SVProgressHUD showWithStatus:s maskType:SVProgressHUDMaskTypeGradient];
    
    
    if ([self.pendingOperations.downloadsInProgress count] == 0 ) {
        
        
        [self closeMe];
        [SVProgressHUD showWithStatus:@"更新已完成！" maskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
        
    }
    
}




//  2. 下载图片文件
- (void)xmlToDB:(NSDictionary *)jsonDict;
{
    
    for (NSMutableDictionary *dict in picArray) {
        
        NSString *fileName = [dict objectForKey:@"name"];
        NSString *writableDBPath = KDocumentName(fileName);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager fileExistsAtPath:writableDBPath];
        if (success) {
            
            [[ZHDBData share] updatePicDownLoaded:[dict objectForKey:@"id"]];
            continue;
        }
        
        [dict setObject:@"image" forKey:@"type"];
        
        
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:dict  delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:[dict objectForKey:@"url"]];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
    
    
    NSMutableArray *pdfArray =  [[ZHDBData share] getPics];
    for (NSMutableDictionary *dict in pdfArray) {
        
        NSString *fileName = [dict objectForKey:@"name"];
        NSString *writableDBPath = KDocumentName(fileName);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager fileExistsAtPath:writableDBPath];
        if (success) {
            
            [[ZHDBData share] updatePicDownLoaded:[dict objectForKey:@"id"]];
            continue;
        }
        
        [dict setObject:@"pdf" forKey:@"type"];
        
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:dict  delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:[dict objectForKey:@"url"]];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
    
    if (self.pendingOperations.downloadsInProgress.count == 0 ) {
        [self closeMe];

        [SVProgressHUD showWithStatus:@"更新已完成！" maskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
        
    }
}

- (void)passDidFinish
{
    
    picArray = [[ZHDBData share] getPics];
    
    
    
    
    for (NSMutableDictionary *dict in picArray) {
        
        NSString *fileName = [dict objectForKey:@"name"];
        NSString *writableDBPath = KDocumentName(fileName);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager fileExistsAtPath:writableDBPath];
        if (success) {
            
//            [[ZHDBData share] updatePicDownLoaded:[dict objectForKey:@"id"]];
            continue;
        }
        
        [dict setObject:@"image" forKey:@"type"];
        
        
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:dict  delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:[dict objectForKey:@"url"]];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
    
    
    if (self.pendingOperations.downloadsInProgress.count == 0 ) {
        
        [self closeMe];
        [SVProgressHUD showWithStatus:@"更新已完成！" maskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
        
    }
    
    
}



- (void)getdata
{
    
    [SVProgressHUD showWithStatus:@"正在下载数据... \n\n请保持屏幕为常亮状态" maskType:SVProgressHUDMaskTypeGradient];

    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];

    NSString *string = [NSString stringWithFormat:@"%@", SharedAppUser.account];
    
    
    NSDictionary *parameters = @{@"userID": string};
    
    NSString *urlString = [NSString stringWithFormat:@"%@Tositrust.asmx/DesignerImages", KHomeUrl];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        
        [SVProgressHUD showWithStatus:@"正在保存数据...  \n\n请保持屏幕为常亮状态" maskType:SVProgressHUDMaskTypeGradient];

        NSError *parseError = nil;

        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        
        
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        NSDictionary *dataDict =  dict[@"StorePICs"];
        
        
        ZHPassDataJSON *passData = [ZHPassDataJSON share];
        passData.delegate = self;
        

        [passData xmlToDB:dataDict];
        
        
        
        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                [SVProgressHUD dismiss];
        if (error.code == -1009) {
            [[Message share] messageAlert:@"请检查网络是否链接"];
        }
//        if (error.code == -1011) {
//            [[Message share] messageAlert:@"链接错误"];
//        }
//        
        else{
            NSString *alertStr = [NSString stringWithFormat:@"服务器错误,请联系管理员告知。错误代码:%d", error.code];
            [[Message share] messageAlert:alertStr];
        }
        NSLog(@"Error: %@", error);
    }];

    
}


-(void)saveUserInfo:(NSDictionary *)dict
{
    NSDictionary *d =  dict[@"ReportUser"];
    

    
    

    SharedAppUser.ID =  d[@"id"][@"text"];
    NSString *subid = d[@"SubCityCode"][@"string"][@"text"];
    SharedAppUser.SubCityCode= subid;
    [Cookie setCookie:@"uuid" value:subid];
    
    SharedAppUser.name = d[@"Name"][@"text"];
    SharedAppUser.phone = d[@"CellPhone"][@"text"];
    SharedAppUser.account = d[@"Name"][@"text"];
    


    [d setValue:d[@"Id"][@"text"] forKey:@"id"];
    [d setValue:[passwordTextField.text md5] forKey:@"timestmp"];
    [d setValue:d[@"Name"][@"text"] forKey:@"account"];
    [d setValue:[NSDate date] forKey:@"date"];
    
    [d setValue:subid forKeyPath:@"SubCityCode" ];
    
    [Cookie setCookie:nameTextField.text value:d];
    [Cookie setCookie:KCurrentUser value:nameTextField.text];
    
    
    [SVProgressHUD showWithStatus:@"登陆成功！" maskType:SVProgressHUDMaskTypeGradient];

    [self closeMe];
}

- (IBAction)login:(UIButton *)button
{
    
    DLog(@"login");
//    [self closeMe];
//    return;
    
    
    
    [UIView animateWithDuration:KDuration animations:^{
        
        loginBackGroundView.frame = RectMake2x(547, 368, 954, 750);
    }];
    
    
    

    
    [nameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];

    if (nameTextField.text.length  == 0) {
        
        [[Message share] messageAlert: @"请填写用户名！"];
        return;
    }
    if (passwordTextField.text.length  == 0) {
        
        [[Message share] messageAlert: @"请填写密码！"];
        return;
    }
    
    
    //   检查网络
    
    [SVProgressHUD showWithStatus:@"正在登录..." maskType:SVProgressHUDMaskTypeGradient];
    
    
    
    dispatch_queue_t queue = dispatch_queue_create("com.ple.queue", NULL);
    dispatch_async(queue, ^(void) {
        

        
            
            if ( [[NetWork shareNetWork] CheckNetwork]) {

                
                
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer = [AFXMLParserResponseSerializer new];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
                
//                NSDictionary *parameters = @{@"userID": @"BED3FA5F9BF747D99AC7EB9E63D75071"};
                NSString *pwd = [[passwordTextField.text md5] uppercaseString];
                NSDictionary *parameters = @{@"userName": nameTextField.text,
                                             @"password": pwd};
                NSString *urlString = [NSString stringWithFormat:@"%@/Login", KHomeUrl];

                [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

  

                    
                    NSError *parseError = nil;
                    
                    NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
                    
                    
                    NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
                    
                    NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
                    
                    if (dict == nil) {
                        [SVProgressHUD dismiss];

                        [[Message share] messageAlert:[NSString stringWithFormat:@"%@", s]];
                        
                        return ;
                    }
                    else {
                        NSLog(@"login success");

                        [self saveUserInfo:dict];
                    }
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [SVProgressHUD dismiss];
                    [[Message share] messageAlert:KString_Server_Error];

                    DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
                }];
                
                
                
                
            }
            else {
                NSDictionary *dict =   [Cookie getCookie:nameTextField.text];
                
                if (  dict.count != 0 ) {
                    

                    if ( [[dict objectForKey:@"timestmp"]   isEqualToString: [passwordTextField.text md5]] ) {
                        
                        
                        [SVProgressHUD showWithStatus:@"登陆成功！" maskType:SVProgressHUDMaskTypeGradient];
                        DLog(@"login S");

                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSelector:@selector(closeMe)];
                            
                        });
                    }
                    else {
                        DLog(@"login F");
                        dispatch_async(dispatch_get_main_queue(), ^{

                            [SVProgressHUD dismiss];
                            [[Message share] messageAlert:@"密码错误。"];
                        });

                    }
                    
                }
                
                else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{

                        [SVProgressHUD dismiss];

                        [[Message share] messageAlert:@"请您连接网络后再次尝试。"];
                    });

                }
            }
            
        
        
        
    });
    
}


- (IBAction)changePassword {
    
    
    [UIView animateWithDuration:KDuration animations:^{
        
        loginBackGroundView.frame = RectMake2x(547, 368, 954, 750);
    }];

    
    [_oldPwdTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_confPwdTextField resignFirstResponder];
    
    if (_user_name.text.length == 0) {
        [[Message share] messageAlert: @"请填写用户名！"];
        return;
    }
    if (_oldPwdTextField.text.length  == 0) {
        [[Message share] messageAlert: @"请填写旧密码！"];
        return;
    }
    if (_pwdTextField.text.length  == 0) {
        [[Message share] messageAlert: @"请填写密码！"];
        return;
    }
    if (_confPwdTextField.text.length  == 0) {
        [[Message share] messageAlert: @"请填写确认密码！"];
        return;
    }
    if ( ! [_pwdTextField.text  isEqualToString:_confPwdTextField.text]) {
        [[Message share] messageAlert: @"请确认密码和确认密码一致！"];
        return;
    }
    
    
    //   检查网络
    
    [SVProgressHUD showWithStatus:@"正在提交..." maskType:SVProgressHUDMaskTypeGradient];
    
    
    
    dispatch_queue_t queue = dispatch_queue_create("com.ple.queue", NULL);
    dispatch_async(queue, ^(void) {

        
        if ( [[NetWork shareNetWork] CheckNetwork]) {
            
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFXMLParserResponseSerializer new];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
            
            NSDictionary *parameters = @{@"userName": _user_name.text,
                                         @"oldPassword": _oldPwdTextField.text,
                                         @"newPassword": _pwdTextField.text};
            NSString *urlString = [NSString stringWithFormat:@"%@/ChangePassword", KHomeUrl];
            
            [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
                
                
                NSError *parseError = nil;
                
                NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
                
                
                NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
                
                NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
                
                if (dict == nil) {
                    [SVProgressHUD dismiss];
                    
                    [[Message share] messageAlert:[NSString stringWithFormat:@"%@", s]];
                    
                    return ;
                }
                else {
                    NSLog(@"login success");
                    [[Message share] messageAlert:[NSString stringWithFormat:@"修改成功"]];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD dismiss];
                [[Message share] messageAlert:KString_Server_Error];
                
                DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
            }];
            
            
            
            
        }
        else {
            NSDictionary *dict =   [Cookie getCookie:nameTextField.text];
            
            if (  dict.count != 0 ) {
                
                
                if ( [[dict objectForKey:@"timestmp"]   isEqualToString: [passwordTextField.text md5]] ) {
                    
                    
                    [SVProgressHUD showWithStatus:@"登陆成功！" maskType:SVProgressHUDMaskTypeGradient];
                    DLog(@"login S");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSelector:@selector(closeMe)];
                        
                    });
                }
                else {
                    DLog(@"login F");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        [[Message share] messageAlert:@"密码错误。"];
                    });
                    
                }
                
            }
            
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    
                    [[Message share] messageAlert:@"请您连接网络后再次尝试。"];
                });
                
            }
        }
        
        
        
        
    });
    
}

#pragma mark - view

- (void)loadView
{
    
    [super loadView];

    nameTextField = [[UITextField alloc] init];
    nameTextField.frame = RectMake2x(177, 498, 801, 88);
    nameTextField.delegate = self;
    nameTextField.textColor = [UIColor blackColor];
    nameTextField.placeholder = @"请输入用户名";
    nameTextField.keyboardType = UIKeyboardAppearanceDefault;

    [self.v1 addSubview:nameTextField];
   
    passwordTextField = [[UITextField alloc] init];
    passwordTextField.frame = RectMake2x(177, 628, 801, 88);
    passwordTextField.delegate = self;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.textColor = [UIColor blackColor];
    passwordTextField.placeholder = @"请输入密码";

    [self.v1 addSubview:passwordTextField];
    

    [self.contentScrollView setContentSize:CGSizeMake(810/2, 1537)];
    [self.contentScrollView setScrollEnabled:NO];
    
    
    self.v1.frame = CGRectMake(0, 0, 810, 1537);
    [_contentScrollView addSubview:self.v1];

    self.v2.frame = CGRectMake(0, 1537/2, 810, 1537);
    [_contentScrollView addSubview:self.v2];
    
    self.v3.frame = CGRectMake(0, 1537/2, 810, 1537);
    [_contentScrollView addSubview:self.v3];
    
    
    
    
    
    
    
#ifdef DEBUG
    nameTextField.text = @"test";
    passwordTextField.text = @"123456";
#endif
    
}


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
    data = [[NSMutableData alloc]init];
    [data setLength:0];
    

    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [UIView animateWithDuration:KDuration animations:^{
        
        loginBackGroundView.frame = RectMake2x(543, 94, 954, 750);
    }];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if (textField == passwordTextField ) {
        [UIView animateWithDuration:KDuration animations:^{
            
            loginBackGroundView.frame = RectMake2x(543, 194, 954, 750);
        }];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    [UIView animateWithDuration:KDuration animations:^{
        
        loginBackGroundView.frame = RectMake2x(543, 194, 954, 750);
    } completion:^(BOOL finished) {
        [self login:nil];
    }];
    return YES;
}



@end
