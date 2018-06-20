//
//  ViewController.m
//  MyNetWroking
//
//  Created by ac hu on 2018/6/20.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "ViewController.h"
#import "RequestNetWork.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RequestNetWork *req = [RequestNetWork new];
    NSString *urlStr = @"http://m.lanlingfuli.com/aif/home/getRecomm";
    NSDictionary *postDic = @{@"agency":@"ios",
                              @"pageIndex":@"1"};
    NSString *token = @"11111111";
    [req reqUrl:urlStr post:postDic token:token suceess:^(id obj) {
        NSLog(@"请求成功：%@",obj);
    } fail:^(NSString *errorStr, NSInteger errorCode) {
        NSLog(@"请求失败：%@",errorStr);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
