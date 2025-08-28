//
//  MRDLNA.h
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import <Foundation/Foundation.h>
#import "CLUPnP.h"
#import "CLUPnPDevice.h"

@protocol DLNADelegate <NSObject>

@optional
/**
 DLNA局域网搜索设备结果
 @param devicesArray <CLUPnPDevice *> 搜索到的设备
 */
- (void)mrdlnaSearchDLNAResult:(NSArray *)devicesArray;
// 搜索错误
- (void)mrdlnaUpnpSearchErrorWithError:(NSError *)error;
// 搜索结束
- (void)mrdlnaUpnpSearchStop;
// 请求异常
- (void)mrdlnaUpnpRequestError:(NSError *)error;
// 设置url响应
- (void)mrdlnaUpnpSetAVTransportURIResponse;
// 获取播放状态
- (void)mrdlnaUpnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info;
//optional
// 未定义的响应/错误
- (void)mrdlnaUpnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML;
// 投屏成功开始播放
- (void)mrdlnaUpnpPlayResponse;
// 暂停响应
- (void)mrdlnaUpnpPauseResponse;
// 停止投屏
- (void)mrdlnaUpnpStopResponse;
// 跳转响应
- (void)mrdlnaUpnpSeekResponse;
// 以前的响应
- (void)mrdlnaUpnpPreviousResponse;
// 下一个响应
- (void)mrdlnaUpnpNextResponse;
// 设置音量响应
- (void)mrdlnaUpnpSetVolumeResponse;
// 设置下一个url响应
- (void)mrdlnaUpnpSetNextAVTransportURIResponse;
// 获取音频信息
- (void)mrdlnaUpnpGetVolumeResponse:(NSString *)volume;
/// 获取播放进度
- (void)mrdlnaUpnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info;

@end

@interface MRDLNA : NSObject

@property(nonatomic,weak)id<DLNADelegate> delegate;

@property(nonatomic, strong) CLUPnPDevice *device;

@property(nonatomic,copy) NSString *playUrl;

@property(nonatomic,assign) NSInteger searchTime;

/**
 单例
 */
+(instancetype)sharedMRDLNAManager;

/**
 搜设备
 */
- (void)startSearch;
/**
 停止搜设备
 */
- (void)stopSearch;

/**
 DLNA投屏
 */
- (void)startDLNA;
/**
 DLNA投屏(首先停止)---投屏不了可以使用这个方法
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop;

/**
 退出DLNA
 */
- (void)endDLNA;

/**
 播放
 */
- (void)dlnaPlay;

/**
 暂停
 */
- (void)dlnaPause;

/**
 设置音量 volume建议传0-100之间字符串
 */
- (void)volumeChanged:(NSString *)volume;

/**
 设置播放进度 seek单位是秒
 */
- (void)seekChanged:(NSInteger)seek;

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url;

/**
 获取播放进度,可通过协议回调使用
 */
- (void)getPositionInfo;

@end
