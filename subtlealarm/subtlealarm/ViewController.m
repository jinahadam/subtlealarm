//
//  ViewController.m
//  subtlealarm
//
//  Created by Jinah Adam on 14/10/14.
//  Copyright (c) 2014 Jinah Adam. All rights reserved.
//

double const INCREMENT = 0.1;
double const STILL_TIME = 5;
double const MOVEMENT_TIME = 3;


#import "ViewController.h"

@interface ViewController () {
    double phoneMovingSeconds;
    double phoneNotMoving;
    double lastValue;
    bool phone_moving;
    bool alarm_status;
    bool trigger_alarm_when_phone_is_still;
    bool sound;
    float phoneVoume;

}

@end

@implementation ViewController

@synthesize moving_timer;
@synthesize stop_timer;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGyro];
    [self config];
    [self setupAudio];
    [self.cirlce setStrokeEnd:0.0 animated:NO];
    [self updateVolumeLabel];
    self.view.backgroundColor = [UIColor neutralColor];


}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(turnOffAlarm:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];

    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];


}

-(void) config {
    phoneMovingSeconds = 0;
    lastValue = 0;
    phoneNotMoving = 0;
    phone_moving = false;
    alarm_status = false;
    trigger_alarm_when_phone_is_still = false;
    sound = false;
}

-(void) setupAudio {

    AVAudioSession *audioSession= [AVAudioSession sharedInstance];

    phoneVoume = audioSession.outputVolume;
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }

    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }

    NSError *error;
    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"wav"];
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];

    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
    self.audioPlayer.numberOfLoops = -1;
    self.audioPlayer.volume = 0;
    [self.audioPlayer setDelegate:self];
    [self.audioPlayer play];

}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqual:@"outputVolume"]) {
        phoneVoume = [change[@"new"] doubleValue];
        [self updateVolumeLabel];
    }
}

-(void)updateVolumeLabel {
    if (phoneVoume < 0.5) {
        self.volumeLabel.text = @"Device Volume is too low.";
    } else {
        self.volumeLabel.text = @"";
    }
}

-(void) setupGyro {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.gyroUpdateInterval = .2;
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];

}

- (void)turnOffAlarm: (NSNotification*) sender {
    self.alarmStatus.text = @"Alarm OFF";
    alarm_status = false;
    trigger_alarm_when_phone_is_still = false;
    [self stopAlarmSound];
    self.view.backgroundColor = [UIColor neutralColor];
}

-(void) playAlarmSound {
    if (!sound) {
        self.audioPlayer.volume = 0.9;
        sound = true;
    }
}

- (void)stopAlarmSound {
    self.audioPlayer.volume = 0;
    sound = false;
}

- (IBAction)triggerAlarm:(id)sender {
    
    if (!alarm_status) {

        if (phoneVoume < 0.5) {
            return;
        }

        LAContext *context = [[LAContext alloc] init];
        __block  NSString *msg;
        
        // set text for the localized fallback button
        context.localizedFallbackTitle = NSLocalizedString(@"TOUCH_ID_FALLBACK",nil);
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"TOUCH_TO_ACTIVATE", nil) reply:
         ^(BOOL success, NSError *authenticationError) {
             if (success) {
                 msg =[NSString stringWithFormat:NSLocalizedString(@"EVALUATE_POLICY_SUCCESS", nil)];
                 trigger_alarm_when_phone_is_still = true;

             } else {
                 msg = [NSString stringWithFormat:NSLocalizedString(@"EVALUATE_POLICY_WITH_ERROR", nil), authenticationError.localizedDescription];
             }
         }];
    }
}

-(void)outputRotationData:(CMRotationRate)rotation
{
    double val = [[NSString stringWithFormat:@" %.2f",rotation.z] doubleValue];
    if (lastValue != val) {
        phone_moving = true;
        if (!moving_timer.isValid)
            moving_timer = [NSTimer scheduledTimerWithTimeInterval:INCREMENT target:self selector:@selector(increasePhoneMovementTimer) userInfo:nil repeats:YES];
        
    } else {
        phone_moving = false;
        [moving_timer invalidate];
        if (!stop_timer.isValid) {
            stop_timer = [NSTimer scheduledTimerWithTimeInterval:INCREMENT target:self selector:@selector(increaseStopTimer) userInfo:nil repeats:YES];
            [self.cirlce setStrokeEnd:0.0 animated:YES];
        }
    }
    
    lastValue = val;
    if (phone_moving && phoneMovingSeconds > MOVEMENT_TIME) {
        self.movementLabel.text = @"Device is in motion";
        phoneNotMoving = 0;
        
        if (alarm_status) {
            [self playAlarmSound];
        }

    } else if (!phone_moving && phoneNotMoving > STILL_TIME) {
        self.movementLabel.text = @"Device is Still";
        phoneMovingSeconds = 0;
        if (trigger_alarm_when_phone_is_still) {
            alarm_status = true;
            self.view.backgroundColor = [UIColor alarmColor];
            self.alarmStatus.text = @"Alarm ON";
            self.movementLabel.text = @"Lock the phone, Unlock to stop the alarm";
        }
    }
}

- (void)increaseStopTimer
{
    if (trigger_alarm_when_phone_is_still) {
        [self.cirlce setStrokeColor:[UIColor grayColor]];
    } else {
        [self.cirlce setStrokeColor:[UIColor grayColorx`]];
    }
    phoneNotMoving = phoneNotMoving + INCREMENT;
    float cir = (phoneNotMoving/STILL_TIME);
    [self.cirlce setStrokeEnd:cir animated:YES];
    
    
}

- (void)increasePhoneMovementTimer
{
    phoneMovingSeconds = phoneMovingSeconds + INCREMENT;
    
}


#pragma "touch id stuff"

//check if touch is enabled.

- (void)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    __block  NSString *msg;
    NSError *error;
    BOOL success;
    
    success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (success) {
        msg =[NSString stringWithFormat:NSLocalizedString(@"TOUCH_ID_IS_AVAILABLE", nil)];
    } else {
        msg =[NSString stringWithFormat:NSLocalizedString(@"TOUCH_ID_IS_NOT_AVAILABLE", nil)];
    }
}


@end



