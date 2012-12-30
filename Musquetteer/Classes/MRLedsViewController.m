//
//  MRLedsViewController.m
//  Musquetteer
//
//  Created by Giordano Scalzo on 12/29/12.
//  Copyright (c) 2012 Melaerre. All rights reserved.
//

#import "MRLedsViewController.h"
#import "Musquetteer.h"

@interface MRLedsViewController (){
    Musquetteer *musquetteer;
    BOOL firstLedOn;
    BOOL secondLedOn;
}
@property(nonatomic, strong)IBOutlet UITextField *hostTxt;
@property(nonatomic, strong)IBOutlet UITextField *portTxt;

@property(nonatomic, strong)IBOutlet UIImageView *firstLed;
@property(nonatomic, strong)IBOutlet UIImageView *secondLed;

@property(nonatomic, strong)IBOutlet UISwitch *firstLedSwitch;
@property(nonatomic, strong)IBOutlet UISwitch *secondLedSwitch;

@property(nonatomic, strong)IBOutlet UIButton *connectBtn;

@end

@implementation MRLedsViewController

- (void)resetStatus{
    self.firstLedSwitch.on = NO;
    self.secondLedSwitch.on = NO;
    self.firstLedSwitch.enabled = NO;
    self.secondLedSwitch.enabled = NO;
    firstLedOn = NO;
    secondLedOn = NO;
}

- (void)changeImage:(UIImageView *)imageToChange enabled:(BOOL)enabled {
    if (enabled) {
        imageToChange.image = [UIImage imageNamed:@"greenLed.png"];
    }else{
        imageToChange.image = [UIImage imageNamed:@"redLed.png"];
    }
}

- (void)renderStatus{
    [self changeImage:self.firstLed enabled:firstLedOn];
    [self changeImage:self.secondLed enabled:secondLedOn];
    self.firstLedSwitch.on = firstLedOn;
    self.secondLedSwitch.on = secondLedOn;
}


- (void)createMusquetteer {
#warning change with OpenUDID or similar
    NSString *clientId = [NSString stringWithFormat:@"musquetteer_%@", @"1"];
    musquetteer = [[Musquetteer alloc] initWithClientId:clientId];
    musquetteer.delegate = self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self createMusquetteer];
    
    [self resetStatus];
    [self renderStatus];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    musquetteer = nil;
}

- (IBAction)onConnectPressed:(id)sender{
    [musquetteer connectToHost:self.hostTxt.text port:[self.portTxt.text integerValue]];
    
	[musquetteer subscribe:@"musquetteer/first_led"];
	[musquetteer subscribe:@"musquetteer/second_led"];
}

- (IBAction)onFirstSwitchChanged:(UISwitch *)sender{
    if (sender.on) {
        [musquetteer publishMsg:@"1" toTopic:@"musquetteer/first_led" retain:YES qos:0];
    } else {
        [musquetteer publishMsg:@"0" toTopic:@"musquetteer/first_led" retain:YES qos:0];
    }
}

- (IBAction)onSecondSwitchChanged:(UISwitch *)sender{
    if (sender.on) {
        [musquetteer publishMsg:@"1" toTopic:@"musquetteer/second_led" retain:YES qos:0];
    } else {
        [musquetteer publishMsg:@"0" toTopic:@"musquetteer/second_led" retain:YES qos:0];
    }
}

- (void)didConnect: (NSUInteger)code{
    NSLog(@"didConnect code [%d]", code);
    [self.connectBtn setTitle:@"Reconnect" forState:UIControlStateNormal];
    self.firstLedSwitch.enabled = YES;
    self.secondLedSwitch.enabled = YES;
}

- (void)didDisconnect{
    NSLog(@"%@", @"didDisconnect");
    [self.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
    [self resetStatus];
    [self renderStatus];
}

- (void) didPublish: (NSUInteger)messageId{
    NSLog(@"didPublish messageId [%d]", messageId);
}

- (void) didReceiveMessage: (NSString*)message topic:(NSString*)topic{
    NSLog(@"didReceiveMessage [%@] in topic [%@]", message, topic);

	if ([topic isEqualToString:@"musquetteer/first_led"]) {
        firstLedOn = [message isEqualToString:@"1"];
	} else if ([topic isEqualToString:@"musquetteer/second_led"]) {
        secondLedOn = [message isEqualToString:@"1"];
	}
    [self renderStatus];
}

- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos{
    
}

- (void) didUnsubscribe: (NSUInteger)messageId{
    
}

- (void) onError:(NSError *)error{
    NSLog(@"onError [%@]    ", error);
}


@end
