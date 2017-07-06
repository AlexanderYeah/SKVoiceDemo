//
//  SKWaveAnimView.h
//  SKVoiceDemo
//
//  Created by AY on 2017/7/6.
//  Copyright © 2017年 AlexanderYeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKWaveAnimView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) NSInteger waveCount;

@property (nonatomic, assign) CGFloat minRadius;

@property (nonatomic, assign) BOOL animating;

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *shapeLayers;

- (instancetype)initWithTintColor:(UIColor *)tintColor minRadius:(CGFloat)minRadius waveCount:(NSInteger)waveCount timeInterval:(NSTimeInterval)timeInterval duration:(NSTimeInterval)duration;

- (void)startAnimating;
- (void)stopAnimating;

@end
