//
//  ViewController.m
//  MyNetWroking
//
//  Created by ac hu on 2018/6/20.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "ViewController.h"
#import "RequestNetWork.h"
#import "FileNetWork.h"

@interface ViewController ()<FileNetWorkDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property(nonatomic,strong)FileNetWork *downFileWork;
@property (weak, nonatomic) IBOutlet UILabel *proLabel;

@end

@implementation ViewController
//self ->含义
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

- (IBAction)downClick:(UIButton *)sender {
//    封装流程
//    1.点击下载->判断是否下载完成，若下载完成则直接返后；若未下载完成，判断是新下载还是断点下载；
//    2.走下载流程或者断点下载流程并存到临时文件中；
//    3.下载成功，删除临时文件，并复制到自己的文件夹中;
//    4.下载失败提示用户，是不下载了还是重新下载；
//    5.此封装是走代理（响应式编程），也可以封装成block（函数式编程）；
    if(_downFileWork == nil){
        NSString* fileUrl = @"http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4";
        //NSString* fileUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
        self.downFileWork = [FileNetWork new];
        _downFileWork.tag = 0;
        _downFileWork.myDeleate = self;
        //第二个参数 需要重新下载还是接着上次的下载
        [_downFileWork downFile:fileUrl isBreakpoint:NO];
    }
}

//暂停下载
- (IBAction)pauseClick:(UIButton *)sender {
    [_downFileWork suspendDown];
}

//取消下载
- (IBAction)cancelBtnClick:(UIButton *)sender {
    [_downFileWork cancelDown];
}

//后台下载
- (IBAction)backDownClick:(UIButton *)sender {
}

//--------------------进度 下载成功 失败回调----------------
//进度返回
-(void)backDownprogress:(float)progress tagFun:(NSInteger)tag{
    self.progressView.progress = progress;
    self.proLabel.text = [NSString stringWithFormat:@"%0.1f%@",progress*100,@"%"];
}

//下载成功
-(void)downSucceed:(NSURL*)url tagFun:(NSInteger)tag{
    self.progressView.progress = 0;
    self.proLabel.text = @"0.0%";
}

//下载失败
-(void)downError:(NSError*)error tagFun:(NSInteger)tag{
    self.progressView.progress = 0;
    self.proLabel.text = @"0.0%";
    [self popError];
}

-(void)popError{
    [[[UIAlertView alloc] initWithTitle:@"下载失败" message:@"请重新下载" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}


@end
