//
//  ConnectInfoModel.h
//  example-OC
//
//  Created by Murphy on 2023/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectInfoModel : NSObject

@property (nonatomic, readonly) NSString * deviceName;

@property (nonatomic, readonly) NSString * context;


+ (instancetype)modelWithDeviceName:(NSString *)deviceName;
@end

NS_ASSUME_NONNULL_END
