//
//  ConnectivityViewModel.h
//  example-OC
//
//  Created by Murphy on 2023/5/15.
//

#import <Foundation/Foundation.h>
@class MCBrowserViewController;
@class ConnectInfoModel;
@class RACSignal<__covariant ValueType>;
@class UIImage;

NS_ASSUME_NONNULL_BEGIN

@interface ConnectivityViewModel : NSObject

@property (nonatomic, readonly, nullable) ConnectInfoModel *model;

@property (nonatomic, readonly) RACSignal<UIImage *> *qrCodeSignl;

/// 接收到的数据
@property (nonatomic, readonly, nullable) NSData *receivedData;

/// 发送方开始广播
- (void)startServer;

/// 开始建立链接
- (void)startConnectWithInfo:(ConnectInfoModel *)model;


@end

NS_ASSUME_NONNULL_END
