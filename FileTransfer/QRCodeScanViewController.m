//
//  QRCodeScanViewController.m
//  example-OC
//
//  Created by Murphy on 2023/5/15.
//

#import "QRCodeScanViewController.h"
#import <SGQRCode/SGQRCode.h>
#import "ConnectInfoModel.h"
#import <YYKit/NSObject+YYModel.h>


@interface QRCodeScanViewController () <SGScanCodeDelegate>

@property (nonatomic) SGScanCode *scanCode;

@end

@implementation QRCodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    _scanCode = [SGScanCode scanCode];
    _scanCode.delegate = self;
    _scanCode.preview = self.view;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.scanCode startRunning];
    });
    
}

- (void)scanCode:(SGScanCode *)scanCode result:(NSString *)result {
    [scanCode stopRunning];
    !self.scanResultBlock ?: self.scanResultBlock([ConnectInfoModel modelWithJSON:result]);
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
