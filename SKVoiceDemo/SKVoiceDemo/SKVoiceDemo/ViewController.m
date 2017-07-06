//
//  ViewController.m
//  SKVoiceDemo
//
//  Created by AY on 2017/7/6.
//  Copyright © 2017年 AlexanderYeah. All rights reserved.
//

#import "ViewController.h"
#import <iflyMSC/iflyMSC.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "SKWaveAnimView.h"

#define MAS_SHORTHAN
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"
#define kMainColor  [UIColor colorWithRed:(66)/255.0 green:(119)/255.0 blue:(238)/255.0 alpha:1.0]

@interface ViewController ()
// 1 录音按钮
@property (nonatomic,strong)UIButton *recordBtn;
// 2 动画view
@property (nonatomic,strong)SKWaveAnimView *waveView;
// 3 textview
@property (nonatomic,strong)UITextView *showTextView;

@end

@implementation ViewController


#pragma mark - 懒加载animView
- (SKWaveAnimView *)waveView
{
    if (!_waveView) {
        // 1 waveView
        _waveView = [[SKWaveAnimView alloc] initWithTintColor:kMainColor minRadius:25 waveCount:5 timeInterval:1 duration:4];
        _waveView.frame = CGRectMake(20, 100, 200, 200);
        [self.view addSubview:_waveView];
        [_waveView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(200);
            make.height.equalTo(200);
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(-100);

        }];
        
        // 2 按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn = btn;
        btn.backgroundColor = [UIColor cyanColor];
        [btn addTarget:self action:@selector(btnClickDown) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(btnClickUpInside) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 30;
        [btn setBackgroundImage:[UIImage imageNamed:@"say_sth"] forState:UIControlStateNormal];
        btn.backgroundColor = kMainColor;
        [self.view addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(60);
            make.height.equalTo(60);
            make.centerX.equalTo(_waveView.mas_centerX);
            make.centerY.equalTo(_waveView.mas_centerY);
        }];
        // 3 显示结果 textview
        _showTextView = [[UITextView alloc]init];
        _showTextView.textColor = kMainColor;
        _showTextView.layer.borderWidth = 1;
        _showTextView.text = @"你说的什么话";
        _showTextView.font = [UIFont systemFontOfSize:22.0f];
        _showTextView.layer.borderColor = kMainColor.CGColor;
        [self.view addSubview:_showTextView];
        [_showTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(300);
            make.height.equalTo(200);
            make.centerX.equalTo(_waveView.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(100);

        }];
        
    }
    return _waveView;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // 1 初始化识别对象
    [self initRecognizer];
    // 2 调用动画
    [self waveView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

#pragma mark - 按钮点下 松手

- (void)btnClickDown{
    NSLog(@"alex-按钮点下");
    // 1 开始录音
    [self startWork];
    // 2 开始动画
    [self.waveView startAnimating];
}

- (void)btnClickUpInside
{
    NSLog(@"alex-按钮松手");
    // 1 结束录音
    [self stopWork];
    // 2 结束动画
    [self.waveView stopAnimating];
}

#pragma mark - 1 初始化识别器
- (void)initRecognizer
{
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
    
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];

        
        }
    }else{ // 有界面
        //单例模式，UI的实例
        if (_iflyRecognizerView == nil) {
            //UI显示剧中
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
            
            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            
        }
        _iflyRecognizerView.delegate = self;
        if (_iflyRecognizerView != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            //设置最长录音时间
            [_iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                //设置语言
                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    
    }
}

#pragma mark - 2 启动听写
- (void)startWork{
        if ([IATConfig sharedInstance].haveView == NO) {//无界面
            // 为nil 再创建
            if(_iFlySpeechRecognizer == nil)
            {
                [self initRecognizer];
            }
            // 取消上次会话
            [_iFlySpeechRecognizer cancel];
            //不带标点
            [IATConfig sharedInstance].dot = [IFlySpeechConstant ASR_PTT_NODOT];
            //设置音频来源为麦克风
            [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
            //设置听写结果格式为json
            [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
            //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
            [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
            
            [_iFlySpeechRecognizer setDelegate:self];
            // 开启监听
            BOOL ret = [_iFlySpeechRecognizer startListening];
            if (ret) {
                
            }else{
                //可能是上次请求未结束，暂不支持多路并发
                NSLog(@"alex-无界面开启录音失败");
            }
        }else{
            // 为nil 再去创建
            if(_iflyRecognizerView == nil)
            {
                [self initRecognizer ];
            }

            //设置音频来源为麦克风
            [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            
            //设置听写结果格式为json
            [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
            //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
            [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
            
            [_iflyRecognizerView start];

        }

}

#pragma mark - 3 停止听写
- (void)stopWork
{
    [_iFlySpeechRecognizer stopListening];
}

#pragma mark - 4 动画的创建


#pragma mark - 以下都为代理监听  
/**
 1 开始说话
 */
- (void)onBeginOfSpeech
{
    NSLog(@"alex-开始说话");
}
/**
 2 停止说话
 */
- (void) onEndOfSpeech
{
    NSLog(@"alex-停止说话");
}

/**
 3 出错
 */
- (void)onError:(IFlySpeechError *)error
{

}
/**
 4  无界面 听写结果回调

 @param results 听写结果
 @param isLast 最后一次
 */
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    NSLog(@"alex-结果输出%@",resultFromJson);
    
    
    if (isLast == NO) {
        _showTextView.text = resultFromJson;
    }
}

/**
 5 有界面 听写结果回调

 @param resultArray 听写结果
 @param isLast 最后一次
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSLog(@"alex-有界面结果回调");
}

/**
 6 取消听写
 */
- (void)onCancel
{
    NSLog(@"alex-取消听写");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
