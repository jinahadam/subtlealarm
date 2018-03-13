//
//  ViewController.h
//  subtlealarm
//
//  Created by Jinah Adam on 14/10/14.
//  Copyright (c) 2014 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CircleView.h"


@import LocalAuthentication;



@interface ViewController : UIViewController <AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *movementLabel;
@property (strong, nonatomic) IBOutlet CircleView *cirlce;
@property (strong, nonatomic) IBOutlet UILabel *alarmStatus;
@property (strong, nonatomic) IBOutlet UIButton *alarmButton;
@property (strong, nonatomic) NSTimer *moving_timer;
@property (strong, nonatomic) NSTimer *stop_timer;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;


@end

