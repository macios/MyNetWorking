//
//  FileNetWork.h
//  MyNetWroking
//
//  Created by ac hu on 2018/6/20.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileNetWorkDelegate<NSObject>

//返回某个下载进程的下载进度
-(void)backDownprogress:(float)progress tagFun:(NSInteger)tag;

//某个下载完成
-(void)downSucceed:(NSURL*)url tagFun:(NSInteger)tag;

//某个下载成功
-(void)downError:(NSError*)error tagFun:(NSInteger)tag;

@end

@interface FileNetWork : NSObject

@property(nonatomic,weak)id<FileNetWorkDelegate>myDeleate;
@property(nonatomic,assign)NSInteger tag; //某个文件下载的的标记

-(void)downFile:(NSString*)fileUrl isBreakpoint:(BOOL)breakpoint;

//暂停 继续 取消 文件下载
-(void)suspendDown;
-(void)cancelDown;
@end
