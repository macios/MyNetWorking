//
//  RequestNetWork.m
//  MyNetWroking
//
//  Created by ac hu on 2018/6/20.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "RequestNetWork.h"

@interface RequestNetWork()<NSURLSessionDataDelegate>

@property(nonatomic,copy)successBlock successBlock;
@property(nonatomic,copy)failBlock failBlock;
@property(nonatomic,strong)NSMutableData *data;

@end

@implementation RequestNetWork

-(NSURLSessionDataTask *)reqUrl:(NSString *)url post:(NSDictionary *)dic token:(NSString *)token suceess:(successBlock)success fail:(failBlock)fail{//block回掉放在主线程
    
    if (url == nil || dic == nil)return nil;
    self.successBlock = success;
    self.failBlock = fail;
    self.data = [[NSMutableData alloc]init];
    
    NSURL *reqUrl = [NSURL URLWithString:url];
    //创建可变请求对象
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:reqUrl];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];//不写也可以，只是口头告诉服务器
    [req setValue:token forHTTPHeaderField:@"token"];//方便服务器获取，服务器从header拿更效率。时效块，有的公司用session
    
    req.HTTPMethod = @"POST";//指定请求方式，共四中
    req.timeoutInterval = 30.f;//设置请求超时时间
    req.HTTPBody = [self converToJsonData:dic];
    //以上代码将body也head封装到了request
    
    //网络传输
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];//将delegate回调放在主队列
    
    //创建请求 Task 该次请求的指针-该次请求的句柄：指向指针的指针**A，将request放到网络任务里
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req];
    //发送请求
    [dataTask resume];//请求过程
    
    return dataTask;
}

#pragma mark - NSURLSessionDataDelegate
//返回过程
//1.接收到服务器响应head数据
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSLog(@"收到请求头数据");
    completionHandler(NSURLSessionResponseAllow);//允许响应
}

//2.接收到服务器数据body数据
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
   //包安顺序传1 2 3 4
    NSLog(@"收到请求体数据");
    [self.data appendData:data];
}

//3.任务完成是调用
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"数据接收完成");
    if (error) {
        self.failBlock(error.description, -100);
        return;
    }
    NSString *jsonStr = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
    if (jsonStr == nil) {
        self.failBlock(@"请求失败", -100);
        return;
    }
    NSDictionary *dic = [self dictionaryWhthJsonStr:jsonStr];
    if (dic == nil) {
        self.failBlock(@"请求失败", -100);
        return;
    }
    self.successBlock(dic);
}

-(void)getErrCode:(NSInteger)code{
    switch (code) {
        case 700:
            
            break;
            
        default:
            break;
    }
}

-(NSData *)converToJsonData:(NSDictionary *)dic{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = @"";
    if (!jsonData) {
        NSLog(@"conver error:%@",error);
        self.failBlock(error.description, -100);
        return nil;
    }else{
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonStr = [jsonStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去掉收尾空白字符与换行字符
    [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return [jsonStr dataUsingEncoding:NSUTF8StringEncoding];//转成二进制
}

-(NSDictionary *)dictionaryWhthJsonStr:(NSString *)jsonStr{
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        self.failBlock(error.description, -100);
        return nil;
    }
    return dic;
}
@end
