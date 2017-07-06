//
//  ViewController.h
//  SKVoiceDemo
//
//  Created by AY on 2017/7/6.
//  Copyright © 2017年 AlexanderYeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iflyMSC/iflyMSC.h>
@interface ViewController : UIViewController<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;//带界面的识别对象


@end

