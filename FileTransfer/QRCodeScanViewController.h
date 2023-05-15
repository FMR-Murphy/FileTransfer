//
//  QRCodeScanViewController.h
//  example-OC
//
//  Created by Murphy on 2023/5/15.
//

#import <UIKit/UIKit.h>
@class  ConnectInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeScanViewController : UIViewController


@property (nonatomic, nullable) void(^scanResultBlock)(ConnectInfoModel * _Nullable model);


@end

NS_ASSUME_NONNULL_END
