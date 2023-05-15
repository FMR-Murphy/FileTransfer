//
//  TTViewController.m
//  example-OC
//
//  Created by Murphy on 2022/8/19.
//

#import "TTViewController.h"


#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "ConnectivityViewModel.h"
#import <YYKit/NSObject+YYModel.h>
#import "ConnectInfoModel.h"
#import "QRCodeScanViewController.h"


@interface TTViewController ()

@property (nonatomic) UIButton * serviceButton;

@property (nonatomic) UIButton * clientButton;

@property (nonatomic) ConnectivityViewModel * viewModel;

@property (nonatomic) UIImageView * imageView;
@property (nonatomic) UITextView * textView;

@end

@implementation TTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.serviceButton];
    [self.view addSubview:self.clientButton];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.textView];
    [self.serviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@30);
        make.trailing.equalTo(@-30);
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(30);
        make.height.equalTo(@40);
    }];
    
    [self.clientButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@30);
        make.trailing.equalTo(@-30);
        make.top.equalTo(self.serviceButton.mas_bottom).offset(30);
        make.height.equalTo(@40);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clientButton.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.height.width.equalTo(@200);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(10);
        make.left.right.equalTo(self.serviceButton);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-20);
    }];
    [self bindAction];
}

- (void)bindAction {
    @weakify(self);
    [[[self.serviceButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.viewModel startServer];
    }];
    
    [[[self.clientButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        QRCodeScanViewController *vc = [[QRCodeScanViewController alloc] init];
        vc.scanResultBlock = ^(ConnectInfoModel * _Nullable model) {
            NSLog(@"二维码信息 - %@", [model modelToJSONObject]);
            /// 扫到信息，开始链接
            [self.viewModel startConnectWithInfo:model];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[RACObserve(self.viewModel, model) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(ConnectInfoModel * _Nullable x) {
        @strongify(self);
        self.textView.text = [x modelToJSONString];
    }];
    
    RAC(self.imageView, image) = self.viewModel.qrCodeSignl;
    
    [[[RACObserve(self.viewModel, receivedData) takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSData * _Nullable x) {
        @strongify(self);
        UIImage *image = [UIImage imageWithData:x];
        self.imageView.image = image;
    }];
}


- (UIButton *)serviceButton {
    if (!_serviceButton) {
        _serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_serviceButton setTitle:@"开始广播" forState:UIControlStateNormal];
        [_serviceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _serviceButton;
}

- (UIButton *)clientButton {
    if (!_clientButton) {
        _clientButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clientButton setTitle:@"开始扫描" forState:UIControlStateNormal];
        [_clientButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _clientButton;
}

- (ConnectivityViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ConnectivityViewModel alloc] init];
    }
    return _viewModel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    }
    return _imageView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.textColor = [UIColor blackColor];
    }
    return _textView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
