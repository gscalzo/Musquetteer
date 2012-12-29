//
//  Musquetteer.m
//
//  Copyright 2012 - Giordano Scalzo. All rights reserved.
//  Based on MosquittoClient by Nicholas Humfrey
//

#import <Foundation/Foundation.h>

@protocol MosquittoClientDeligate

- (void) didConnect: (NSUInteger)code;
- (void) didDisconnect;
- (void) didPublish: (NSUInteger)messageId;

// FIXME: create MosquittoMessage class
- (void) didReceiveMessage: (NSString*)message topic:(NSString*)topic;
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos;
- (void) didUnsubscribe: (NSUInteger)messageId;

@end


@interface Musquetteer : NSObject {
    struct mosquitto *mosq;
    NSTimer *timer;
}

@property (readwrite,strong) NSString *host;
@property (readwrite,assign) unsigned short port;
@property (readwrite,strong) NSString *username;
@property (readwrite,strong) NSString *password;
@property (readwrite,assign) unsigned short keepAlive;
@property (readwrite,assign) BOOL cleanSession;
@property (readwrite,strong) id<MosquittoClientDeligate> delegate;

+ (void) initialize;
+ (NSString*) version;


- (id) initWithClientId: (NSString *)clientId;
- (void) setMessageRetry: (NSUInteger)seconds;
- (void) connect;
- (void) connectToHost: (NSString*)host port:(NSInteger)port;
- (void) reconnect;
- (void) disconnect;
- (void)publishMsg: (NSString *)payload toTopic:(NSString *)topic retain:(BOOL)retain qos:(NSUInteger)qos;

- (void)subscribe: (NSString *)topic;
- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos;
- (void)unsubscribe: (NSString *)topic;

@end
