//
//  ConnectInfoModel.m
//  example-OC
//
//  Created by Murphy on 2023/5/15.
//

#import "ConnectInfoModel.h"

@interface ConnectInfoModel ()

@property (nonatomic) NSString * deviceName;

@property (nonatomic) NSString * context;


@end


@implementation ConnectInfoModel

+ (instancetype)modelWithDeviceName:(NSString *)deviceName {
    ConnectInfoModel *model = [[ConnectInfoModel alloc] init];
    model.deviceName = deviceName;
    return model;
}

- (NSString *)context {
    if (!_context) {
        _context = @(arc4random() % 1000000).stringValue;
    }
    return _context;
}
@end
