//
//  FileNetWork.m
//  MyNetWroking
//
//  Created by ac hu on 2018/6/20.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "FileNetWork.h"
#import <CommonCrypto/CommonDigest.h>

@interface FileNetWork()<NSURLSessionDelegate>
{
    BOOL _mIsSuspend;
    NSString *_mFileName;
}
@property(nonatomic,strong)NSURLSession* session;
@property(nonatomic,strong)NSURLSessionDownloadTask* downloadTask;
@property(nonatomic,strong)NSData* resumeData;

@property(nonatomic,strong)NSMutableData * mutableData;


@end

@implementation FileNetWork

//创建下载任务
-(void)downFile:(NSString *)fileUrl isBreakpoint:(BOOL)breakpoint{
    if (fileUrl == nil) return;
    self->_mFileName = [self md5:fileUrl];
    //1.创建
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.allowsCellularAccess = YES;//允许蜂窝
    
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //2.创建task任务
    NSURL *url = [NSURL URLWithString:fileUrl];
    if (breakpoint == NO) {
        //如果不是断点就新下载
        self.downloadTask = [self.session downloadTaskWithURL:url];
    }else{
        //如果是断点就继续下载
        [self goOnDownLoad];
    }
    
//    3、执行task 任务下载
    [self.downloadTask resume];
}

//收到数据回调方法
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    //拼接数据
    [self.mutableData appendData:data];
}

/*
 1.当接收到下载数据的时候调用,可以在该方法中监听文件下载的进度
 该方法会被调用多次
 totalBytesWritten:已经写入到文件中的数据大小
 totalBytesExpectedToWrite:目前文件的总大小
 bytesWritten:本次下载的文件数据大小
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //会自动缓存到临时文件中
    float downPro   = 1.0 * totalBytesWritten/totalBytesExpectedToWrite;
    if(self.myDeleate!= nil)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myDeleate backDownprogress:downPro tagFun:self.tag];
        });
}

/*
 2.下载完成之后调用该方法
 */
-(void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location{
    //拼接Doc 更换的路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *appendPath = [NSString stringWithFormat:@"/%@.mp4",self->_mFileName];
    NSString *file = [documentsPath stringByAppendingString:appendPath];
    
    //创建文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file error:nil];
    
    //将视频资源从原有路径移动到自己指定的路径
    BOOL success = [manager copyItemAtPath:location.path toPath:file error:nil];
    if (success) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSURL *url = [[NSURL alloc]initFileURLWithPath:file];
            if(self.myDeleate!= nil)
                [self.myDeleate downSucceed:url tagFun:self.tag];
        });
        _mFileName = nil;
    }
    
    //已经拷贝 删除缓存文件
    [manager removeItemAtPath:location.path error:nil];
}

/*
 4.请求完成之后调用
 如果请求失败，那么error有值
 */

//下载失败调用
-(void)URLSession:(nonnull NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if(error!=nil&& self.myDeleate!= nil && error.code != -999)
        [self.myDeleate downError:error tagFun:self.tag];
    _mFileName = nil;
}

//继续下载
-(void)goOnDownLoad{
    //获取临时文件
    NSFileManager* fm = [NSFileManager defaultManager];
    NSData* fileData = [fm  contentsAtPath:[self getTmpFileUrl]];
    self.downloadTask = [self.session downloadTaskWithResumeData:fileData];
}

//获取临时文件目录
-(NSString*)getTmpFileUrl{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    return  [NSString stringWithFormat:@"%@/%@.tmp",documentsPath,self->_mFileName];
}

//用url获取文件名称
- (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}

//暂停下载
-(void)suspendDown{
    
    if(_mIsSuspend)
        [self.downloadTask resume];//开始
    
    else
        [self.downloadTask suspend];//暂停
    
    
    _mIsSuspend = !_mIsSuspend;
    
}

//取消下载
-(void)cancelDown{
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        [resumeData writeToFile:[self getTmpFileUrl] atomically:NO];
    }];
}
@end
