//
//  CLUPnPRenderer.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnP.h"
#import "GDataXMLNode.h"
#import "CLUPnPAction.h"

// DIDL-Lite templates for different media types
#define DIDL_VIDEO_TEMPLATE @"<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:sec=\"http://www.sec.co.kr/\" xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\"><item id=\"f-0\" parentID=\"0\" restricted=\"0\"><dc:title>%@</dc:title><dc:creator>%@</dc:creator><upnp:class>object.item.videoItem</upnp:class><res protocolInfo=\"http-get:*:video/*:DLNA.ORG_OP=01;DLNA.ORG_CI=0;DLNA.ORG_FLAGS=01700000000000000000000000000000\" sec:URIType=\"public\">%@</res></item></DIDL-Lite>"


@implementation CLUPnPRenderer

- (instancetype)initWithModel:(CLUPnPDevice *)model{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)setModel:(CLUPnPDevice *)model{
    _model = model;
}

#pragma mark - DIDL-Lite Helper Methods

- (NSString *)createDIDLForURL:(NSString *)urlStr title:(NSString *)title creator:(NSString *)creator {
    if (!title || title.length == 0) {
        title = @""; // Unknown Media
    }
    if (!creator || creator.length == 0) {
        creator = @""; // Unknown
    }
    
    NSString *template = [self getDIDLTemplateForURL:urlStr];
    return [NSString stringWithFormat:template, title, creator, urlStr];
}

- (NSString *)getDIDLTemplateForURL:(NSString *)urlStr {
    // 仅支持视频，需要支持其他格式，去翻0.3.0源码
    return DIDL_VIDEO_TEMPLATE;
}

#pragma mark -
#pragma mark -- AVTransport动作 --
- (void)setAVTransportURL:(NSString *)urlStr{
    if (!urlStr || urlStr.length == 0) {
        CLLog(@"Invalid URL: %@", urlStr);
        return;
    }
    
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:urlStr forName:@"CurrentURI"];
    [action setArgumentValue:[self createDIDLForURL:urlStr title:nil creator:nil] forName:@"CurrentURIMetaData"];
    [self postRequestWith:action];
}

- (void)setAVTransportURL:(NSString *)urlStr title:(NSString *)title creator:(NSString *)creator {
    if (!urlStr || urlStr.length == 0) {
        CLLog(@"Invalid URL: %@", urlStr);
        return;
    }
    
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:urlStr forName:@"CurrentURI"];
    [action setArgumentValue:[self createDIDLForURL:urlStr title:title creator:creator] forName:@"CurrentURIMetaData"];
    [self postRequestWith:action];
}

- (void)setNextAVTransportURI:(NSString *)urlStr{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetNextAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:urlStr forName:@"NextURI"];
    [action setArgumentValue:@"" forName:@"NextURIMetaData"];
    [self postRequestWith:action];
}

- (void)play{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Play"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"1" forName:@"Speed"];
    [self postRequestWith:action];
}

- (void)pause{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Pause"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)stop{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Stop"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)next{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Next"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)previous{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Previous"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)getPositionInfo{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetPositionInfo"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)getTransportInfo{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetTransportInfo"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)seek:(float)relTime{
    [self seekToTarget:[NSString stringWithDurationTime:relTime] Unit:unitREL_TIME];
}

- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Seek"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:unit forName:@"Unit"];
    [action setArgumentValue:target forName:@"Target"];
    [self postRequestWith:action];
}

#pragma mark -
#pragma mark -- RenderingControl动作 --
- (void)getVolume{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetVolume"];
    [action setServiceType:CLUPnPServiceRenderingControl];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [self postRequestWith:action];
}

- (void)setVolumeWith:(NSString *)value{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetVolume"];
    [action setServiceType:CLUPnPServiceRenderingControl];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [action setArgumentValue:value forName:@"DesiredVolume"];
    [self postRequestWith:action];
}

#pragma mark -
#pragma mark -- 发送动作请求 --
- (void)postRequestWith:(CLUPnPAction *)action{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL       *url = [NSURL URLWithString:[action getPostUrlStrWith:_model]];
    NSString    *postXML = [action getPostXMLFile];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[action getSOAPAction] forHTTPHeaderField:@"SOAPAction"];
    request.HTTPBody = [postXML dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data == nil) {
            [self _UndefinedResponse:nil postXML:postXML];
            return;
        }else{
            [self parseRequestResponseData:data postXML:postXML];
        }
    }];
    [dataTask resume];
}

#pragma mark -
#pragma mark -- 动作响应 --
- (void)parseRequestResponseData:(NSData *)data postXML:(NSString *)postXML{
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *element = [bigArray objectAtIndex:i];
        NSArray *needArr = [element children];
        if ([[element name] hasSuffix:@"Body"]) {
            [self resultsWith:needArr postXML:postXML];
        }else{
            [self _UndefinedResponse:[xmlEle XMLString] postXML:postXML];
        }
    }
}

- (void)resultsWith:(NSArray *)array postXML:(NSString *)postXML{
    for (int i = 0; i < array.count; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        if ([[ele name] hasSuffix:@"SetAVTransportURIResponse"]) {
            [self _SetAVTransportURIResponse];
            [self getTransportInfo];
        }else if ([[ele name] hasSuffix:@"SetNextAVTransportURIResponse"]){
            [self _SetNextAVTransportURIResponse];
        }else if ([[ele name] hasSuffix:@"PauseResponse"]){
            [self _PauseResponse];
        }else if ([[ele name] hasSuffix:@"PlayResponse"]){
            [self _PlayResponse];
        }else if ([[ele name] hasSuffix:@"StopResponse"]){
            [self _StopResponse];
        }else if ([[ele name] hasSuffix:@"SeekResponse"]){
            [self _SeekResponse];
        }else if ([[ele name] hasSuffix:@"NextResponse"]){
            [self _NextResponse];
        }else if ([[ele name] hasSuffix:@"PreviousResponse"]){
            [self _PreviousResponse];
        }else if ([[ele name] hasSuffix:@"SetVolumeResponse"]){
            [self _SetVolumeResponse];
        }else if ([[ele name] hasSuffix:@"GetVolumeResponse"]){
            [self _GetVolumeSuccessWith:[ele children]];
        }else if ([[ele name] hasSuffix:@"GetPositionInfoResponse"]){
            [self _GetPositionInfoResponseWith:[ele children]];
        }else if ([[ele name] hasSuffix:@"GetTransportInfoResponse"]){
            [self _GetTransportInfoResponseWith:[ele children]];
        }else{
            [self _UndefinedResponse:[ele XMLString] postXML:postXML];
        }
    }
}

#pragma mark -
#pragma mark -- 回调协议 --
- (void)_SetAVTransportURIResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetAVTransportURIResponse)]) {
        [self.delegate upnpSetAVTransportURIResponse];
    }
}

- (void)_SetNextAVTransportURIResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetNextAVTransportURIResponse)]) {
        [self.delegate upnpSetNextAVTransportURIResponse];
    }
}

- (void)_PauseResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPauseResponse)]) {
        [self.delegate upnpPauseResponse];
    }
}

- (void)_PlayResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPlayResponse)]) {
        [self.delegate upnpPlayResponse];
    }
}

- (void)_StopResponse{
    if ([self.delegate respondsToSelector:@selector(upnpStopResponse)]) {
        [self.delegate upnpStopResponse];
    }
}

- (void)_SeekResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSeekResponse)]) {
        [self.delegate upnpSeekResponse];
    }
}

- (void)_NextResponse{
    if ([self.delegate respondsToSelector:@selector(upnpNextResponse)]) {
        [self.delegate upnpNextResponse];
    }
}

- (void)_PreviousResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPreviousResponse)]) {
        [self.delegate upnpPreviousResponse];
    }
}

- (void)_SetVolumeResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetVolumeResponse)]) {
        [self.delegate upnpSetVolumeResponse];
    }
}

- (void)_GetVolumeSuccessWith:(NSArray *)array{
    for (int j = 0; j < array.count; j++) {
        GDataXMLElement *eleXml = [array objectAtIndex:j];
        if ([[eleXml name] isEqualToString:@"CurrentVolume"]) {
            if ([self.delegate respondsToSelector:@selector(upnpGetVolumeResponse:)]) {
                [self.delegate upnpGetVolumeResponse:[eleXml stringValue]];
            }
        }
    }
}

- (void)_GetPositionInfoResponseWith:(NSArray *)array{
    CLUPnPAVPositionInfo *info = [[CLUPnPAVPositionInfo alloc] init];
    [info setArray:array];
    if ([self.delegate respondsToSelector:@selector(upnpGetPositionInfoResponse:)]) {
        [self.delegate upnpGetPositionInfoResponse:info];
    }
}

- (void)_GetTransportInfoResponseWith:(NSArray *)array{
    CLUPnPTransportInfo *info = [[CLUPnPTransportInfo alloc] init];
    [info setArray:array];
    if ([self.delegate respondsToSelector:@selector(upnpGetTransportInfoResponse:)]) {
        [self.delegate upnpGetTransportInfoResponse:info];
    }
}

- (void)_UndefinedResponse:(id)response postXML:(NSString *)postXML{
    NSLog(@"===========发送信息:%@ \n",postXML);
    NSLog(@"===========响应信息:%@ \n",response);
    if ([self.delegate respondsToSelector:@selector(upnpUndefinedResponse:postXML:)]) {
        [self.delegate upnpUndefinedResponse:response postXML:postXML];
    }
}

@end
