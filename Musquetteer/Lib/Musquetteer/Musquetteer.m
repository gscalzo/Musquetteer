//
//  Musquetteer.m
//
//  Copyright 2012 - Giordano Scalzo. All rights reserved.
//  Based on MosquittoClient by Nicholas Humfrey
//

#import "Musquetteer.h"
#import "mosquitto.h"

@interface Musquetteer () {
    struct mosquitto *mosq;
    NSTimer *timer;
}

@end

@implementation Musquetteer

//@synthesize host;
//@synthesize port;
//@synthesize username;
//@synthesize password;
//@synthesize keepAlive;
//@synthesize cleanSession;
//@synthesize delegate;


static void on_connect(struct mosquitto *mosq, void *obj, int rc)
{
    Musquetteer* client = (__bridge Musquetteer*)obj;
    [[client delegate] didConnect:(NSUInteger)rc];
}

static void on_disconnect(struct mosquitto *mosq, void *obj, int rc)
{
    Musquetteer* client = (__bridge Musquetteer*)obj;
    [[client delegate] didDisconnect];
}

static void on_publish(struct mosquitto *mosq, void *obj, int message_id)
{
    Musquetteer* client = (__bridge Musquetteer*)obj;
    [[client delegate] didPublish:(NSUInteger)message_id];
}

static void on_message(struct mosquitto *mosq, void *obj, const struct mosquitto_message *message)
{
    Musquetteer* client = (__bridge Musquetteer*)obj;
    NSString *topic = [NSString stringWithUTF8String: message->topic];
    NSString *payload = [[NSString alloc] initWithBytes:message->payload
                                                  length:message->payloadlen
                                                encoding:NSUTF8StringEncoding];

    // FIXME: create MosquittoMessage class instead
    [[client delegate] didReceiveMessage:payload topic:topic];
}

static void on_subscribe(struct mosquitto *mosq, void *obj, int message_id, int qos_count, const int *granted_qos)
{
    Musquetteer* client = (__bridge Musquetteer*)obj;
    // FIXME: implement this
    [[client delegate] didSubscribe:message_id grantedQos:nil];
}

static void on_unsubscribe(struct mosquitto *mosq, void *obj, int message_id)
{
    Musquetteer* client = (__bridge Musquetteer*)obj;
    [[client delegate] didUnsubscribe:message_id];
}

+ (void)initialize {
    mosquitto_lib_init();
}

+ (NSString*)version {
    int major, minor, revision;
    mosquitto_lib_version(&major, &minor, &revision);
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, revision];
}

- (id) initWithClientId: (NSString*) clientId {
    if ((self = [super init])) {
        const char* cstrClientId = [clientId cStringUsingEncoding:NSUTF8StringEncoding];
        self.host = @"localhost";
        self.port = 1883;
        self.keepAlive = 60;
        self.cleanSession = YES;

        mosq = mosquitto_new(cstrClientId, self.cleanSession, (__bridge void *)(self));
        mosquitto_connect_callback_set(mosq, on_connect);
        mosquitto_disconnect_callback_set(mosq, on_disconnect);
        mosquitto_publish_callback_set(mosq, on_publish);
        mosquitto_message_callback_set(mosq, on_message);
        mosquitto_subscribe_callback_set(mosq, on_subscribe);
        mosquitto_unsubscribe_callback_set(mosq, on_unsubscribe);
        timer = nil;
    }
    return self;
}


- (void) connect {
    const char *cstrHost = [self.host cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cstrUsername = NULL, *cstrPassword = NULL;

    if (self.username)
        cstrUsername = [self.username cStringUsingEncoding:NSUTF8StringEncoding];

    if (self.password)
        cstrPassword = [self.password cStringUsingEncoding:NSUTF8StringEncoding];

#warning check for errors
    mosquitto_username_pw_set(mosq, cstrUsername, cstrPassword);

    mosquitto_connect(mosq, cstrHost, self.port, self.keepAlive);

#warning hook into iOS Run Loop select()

    // Setup timer to handle network events
    // FIXME: better way to do this - hook into iOS Run Loop select() ?
    // or run in seperate thread?
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 // 10ms
                                             target:self
                                           selector:@selector(loop:)
                                           userInfo:nil
                                            repeats:YES];
}

- (void) connectToHost: (NSString*)host port:(NSInteger)port {
    self.host = host;
    self.port = port;
    [self connect];
}

- (void) reconnect {
    mosquitto_reconnect(mosq);
}

- (void) disconnect {
    mosquitto_disconnect(mosq);
}

- (void) loop: (NSTimer *)timer {
    mosquitto_loop(mosq, 1, 1);
}

- (void)publishMsg: (NSString *)payload toTopic:(NSString *)topic retain:(BOOL)retain qos:(NSUInteger)qos{
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[payload cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_publish(mosq, NULL, cstrTopic, [payload length], cstrPayload, qos, retain);
}

- (void)subscribe: (NSString *)topic {
    [self subscribe:topic withQos:0];
}

- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_subscribe(mosq, NULL, cstrTopic, qos);
}

- (void)unsubscribe: (NSString *)topic {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_unsubscribe(mosq, NULL, cstrTopic);
}


- (void) setMessageRetry: (NSUInteger)seconds{
    mosquitto_message_retry_set(mosq, (unsigned int)seconds);
}


// FIXME: how and when to call mosquitto_lib_cleanup() ?

@end
