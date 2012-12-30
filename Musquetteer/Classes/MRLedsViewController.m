//
//  MRLedsViewController.m
//  Musquetteer
//
//  Created by Giordano Scalzo on 12/29/12.
//  Copyright (c) 2012 Melaerre. All rights reserved.
//

#import "MRLedsViewController.h"

@interface MRLedsViewController ()

@property(nonatomic, strong)IBOutlet UIImageView *firstLed;
@property(nonatomic, strong)IBOutlet UIImageView *secondLed;

@property(nonatomic, strong)IBOutlet UISwitch *firstLedSwitch;
@property(nonatomic, strong)IBOutlet UISwitch *secondLedSwitch;

@end

@implementation MRLedsViewController

- (void)resetStatus{
    self.firstLedSwitch.on = NO;
    self.secondLedSwitch.on = NO;
}

- (void)changeImage:(UIImageView *)imageToChange enabled:(BOOL)enabled {
    if (enabled) {
        imageToChange.image = [UIImage imageNamed:@"greenLed.png"];
    }else{
        imageToChange.image = [UIImage imageNamed:@"redLed.png"];
    }
}

- (void)renderLeds{
    [self changeImage:self.firstLed enabled:self.firstLedSwitch.on];
    [self changeImage:self.secondLed enabled:self.secondLedSwitch.on];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self resetStatus];
    [self renderLeds];
}

@end
