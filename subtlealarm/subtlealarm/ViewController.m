//
//  ViewController.m
//  subtlealarm
//
//  Created by Jinah Adam on 14/10/14.
//  Copyright (c) 2014 Jinah Adam. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    double timerCount;
    double phoneMovingSeconds;
    double lastValue;
    bool phone_moving;
    bool alarm_status;

}

@end

@implementation ViewController

@synthesize timer;
@synthesize moving_timer;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.gyroUpdateInterval = .2;
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];
    
    
    timerCount = 0;
    phoneMovingSeconds = 0;
    lastValue = 0;
    phone_moving = false;
    alarm_status = false;


}
- (IBAction)triggerAlarm:(id)sender {
    
    if (!alarm_status) {
        LAContext *context = [[LAContext alloc] init];
        __block  NSString *msg;
        
        // set text for the localized fallback button
        context.localizedFallbackTitle = NSLocalizedString(@"TOUCH_ID_FALLBACK",nil);
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"TOUCH_TO_ACTIVATE", nil) reply:
         ^(BOOL success, NSError *authenticationError) {
             if (success) {
                 msg =[NSString stringWithFormat:NSLocalizedString(@"EVALUATE_POLICY_SUCCESS", nil)];
                 
                 alarm_status = false;
                 NSLog(@"alarm on");
                 
                 
             } else {
                 msg = [NSString stringWithFormat:NSLocalizedString(@"EVALUATE_POLICY_WITH_ERROR", nil), authenticationError.localizedDescription];
             }
             // [self printResult:self.textView message:msg];
         }];
    } else {
        
        NSLog(@"alarm is already on");
    }
}

-(void)outputRotationData:(CMRotationRate)rotation
{
    double val = [[NSString stringWithFormat:@" %.2f",rotation.z] doubleValue];
    if (lastValue != val) {
        phone_moving = true;
        if (!moving_timer.isValid)
            moving_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increasePhoneMovementTimer) userInfo:nil repeats:YES];
        
    } else {
        phone_moving = false;
        phoneMovingSeconds = 0;
        [moving_timer invalidate];
        
        
    }
    
    lastValue = val;
    if (phone_moving && phoneMovingSeconds > 5) {
        self.movementLabel.text = @"Phone is Moving for 5 seconds";
        
    } else {
        self.movementLabel.text = @"Phone is Still";
        
    }
    
    
    
}


- (IBAction)activateAlarm:(id)sender {
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
    
}

- (void)increasePhoneMovementTimer
{
    phoneMovingSeconds++;
   // NSLog(@"%f phone moving timer", phoneMovingSeconds);
    
}

- (void)increaseTimerCount
{
    timerCount++;
    
    
   // NSLog(@"Activating Lock in %f seconds",5.9-timerCount);
    
    
    if (timerCount == 5) {
      //  NSLog(@"5 seconds passed");
        timerCount = 0;
        [timer invalidate];
    }
}


#pragma "touch id stuff"

//check if touch is enabled.

- (void)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    __block  NSString *msg;
    NSError *error;
    BOOL success;
    
    // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
    success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (success) {
        msg =[NSString stringWithFormat:NSLocalizedString(@"TOUCH_ID_IS_AVAILABLE", nil)];
    } else {
        msg =[NSString stringWithFormat:NSLocalizedString(@"TOUCH_ID_IS_NOT_AVAILABLE", nil)];
    }
    // [super printResult:self.textView message:msg];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
