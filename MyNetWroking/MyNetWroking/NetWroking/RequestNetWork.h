//
//  RequestNetWork.h
//  MyNetWroking
//
//  Created by ac hu on 2018/6/20.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^successBlock)(id obj);
typedef void (^failBlock)(NSString *errorStr,NSInteger errorCode);

@interface RequestNetWork : NSObject
-(NSURLSessionDataTask *)reqUrl:(NSString *)url post:(NSDictionary *)dic token:(NSString *)token suceess:(successBlock)success fail:(failBlock)fail;
@end
