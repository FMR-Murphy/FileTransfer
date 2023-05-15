//
//  ConnectivityViewModel.m
//  example-OC
//
//  Created by Murphy on 2023/5/15.
//

/**
 发送方
 1、创建 MCPeerID
 2、创建 MCSession
 3、创建服务 MCNearbyServiceAdvertiser
    3.1 发送广播 -[MCNearbyServiceAdvertiser startAdvertisingPeer]
 
 接收方
 4、创建 MCPeerID
 5、创建 MCSession
 6、搜索正在广播的设备 MCNearbyServiceBrowser
    6.1 搜索到设备 MCNearbyServiceBrowserDelegate   - (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
    6.2 选择设备，邀请加入链接 - [MCNearbyServiceBrowser invitePeer:(MCPeerID *)peerID toSession:(MCSession *)session withContext:(nullable NSData *)context timeout:(NSTimeInterval)timeout]
 发送方
 7、接到邀请，同意邀请
 MCNearbyServiceAdvertiserDelegate - (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
 
 8、链接成功，发送数据  MCSessionDelegate - (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
 */

#import "ConnectivityViewModel.h"
#import "ConnectInfoModel.h"
#import <YYKit/NSObject+YYModel.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <SGQRCode/SGQRCode.h>

/// targets --> info.plist --> Bonjour services --> _connect._tcp   格式
static NSString * const kServiceType = @"connect";


@interface ConnectivityViewModel () <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

/// =============== 通用信息
/// 标识ID
@property (nonatomic) MCPeerID *peerId;
/// 会话
@property (nonatomic) MCSession *mSession;

/// =============== 发送方保存的信息
/// 广播服务
@property (nonatomic) MCNearbyServiceAdvertiser *serviceAdvertiser;

/// 发送方信息
@property (nonatomic, nullable) ConnectInfoModel *model;

/// 接收方 ID
@property (nonatomic) MCPeerID * targetId;

/// 二维码生成成功
@property (nonatomic) RACSignal<UIImage *> *qrCodeSignl;

/// =============== 接收方保存的信息
/// 设备搜索
@property (nonatomic) MCNearbyServiceBrowser *searchBrowser;

/// 发送方信息，设备匹配用
@property (nonatomic, nullable) ConnectInfoModel *senderModel;

/// 接收到的数据
@property (nonatomic) NSData *receivedData;

@end

@implementation ConnectivityViewModel

#pragma mark - public
/// 发送方开始广播
- (void)startServer {
    self.model = [ConnectInfoModel modelWithDeviceName:self.peerId.displayName];
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerId discoveryInfo:[self.model modelToJSONObject] serviceType:kServiceType];
    self.serviceAdvertiser.delegate = self;
    [self.serviceAdvertiser startAdvertisingPeer];
}

/// 开始搜索附近设备
- (void)startConnectWithInfo:(ConnectInfoModel *)model {
    self.senderModel = model;
    [self.searchBrowser startBrowsingForPeers];
}

#pragma mark - MCSessionDelegate
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSLog(@"%s -- %@", __func__, @(state));
    
    if (state == MCSessionStateConnected && self.targetId) {
        // 链接建立成功，开始发送数据
        NSString *path = [[NSBundle mainBundle] pathForResource:@"zhizhuxia" ofType:@"jpg"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        NSError *error;
        [self.mSession sendData:data toPeers:@[self.targetId] withMode:MCSessionSendDataReliable error:&error];
        if (error) {
            NSLog(@"发送失败 - %@", error);
        }
    }
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"%s", __func__);
    /// 接收到数据
    self.receivedData = data;
    
}

// Start receiving a resource from remote peer.
- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress {
    NSLog(@"%s", __func__);

}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(nullable NSURL *)localURL
                          withError:(nullable NSError *)error {
    NSLog(@"%s", __func__);

}

- (void)session:(nonnull MCSession *)session didReceiveStream:(nonnull NSInputStream *)stream withName:(nonnull NSString *)streamName fromPeer:(nonnull MCPeerID *)peerID {
    
}


#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)            advertiser:(MCNearbyServiceAdvertiser *)advertiser
  didReceiveInvitationFromPeer:(MCPeerID *)peerID
                   withContext:(nullable NSData *)context
             invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler {
    // 接到邀请，同意链接
    ConnectInfoModel *contextModel = [ConnectInfoModel modelWithJSON:context];
    if ([contextModel.context isEqualToString:self.model.context]) {
        !invitationHandler ?: invitationHandler(YES, self.mSession);
        self.targetId = peerID;
        NSLog(@"%s -- 同意链接", __func__);
        
    } else {
        NSLog(@"%s -- 拒绝链接", __func__);
    }
}

// optional
// Advertising did not start due to an error.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    
}

#pragma mark - MCNearbyServiceBrowserDelegate
- (void)        browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info {
    /// 搜索附近设备
    ConnectInfoModel * discoveryInfo = [ConnectInfoModel modelWithJSON:info];
    
    if ([discoveryInfo.context isEqualToString:self.senderModel.context ]) {
        // 设备匹配成功，邀请建立链接
        [self.searchBrowser stopBrowsingForPeers];
        [self.searchBrowser invitePeer:peerID toSession:self.mSession withContext:[info modelToJSONData] timeout:10];
    }
}

// A nearby peer has stopped advertising.
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    // 失去链接
}

//@optional
// Browsing did not start due to an error.
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    
}


#pragma mark - lazy
- (MCPeerID *)peerId {
    if (!_peerId) {
        _peerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    }
    return _peerId;
}

- (MCSession *)mSession {
    if (!_mSession) {
        _mSession = [[MCSession alloc] initWithPeer:self.peerId];
        _mSession.delegate = self;
    }
    return _mSession;
}

- (MCNearbyServiceBrowser *)searchBrowser {
    if (!_searchBrowser) {
        _searchBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerId serviceType:kServiceType];
        _searchBrowser.delegate = self;
    }
    return _searchBrowser;
}

- (RACSignal<UIImage *> *)qrCodeSignl {
    if (!_qrCodeSignl) {
        _qrCodeSignl = [[RACObserve(self, model) filter:^BOOL(id  _Nullable value) {
            return value;
        }] map:^id _Nullable(ConnectInfoModel * _Nullable value) {
            return [SGGenerateQRCode generateQRCodeWithData:[value modelToJSONString] size:200];
        }];
    }
    return _qrCodeSignl;
}

@end
