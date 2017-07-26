//
//  ViewController.m
//  MySnake
//
//  Created by 杜俊楠 on 2017/7/18.
//  Copyright © 2017年 杜俊楠. All rights reserved.
//

//每个格子为20*20
//横向设定为20*15 = 300
//纵向设定为20*25 = 500

#define btnHeight 50
#define sqrHeight 20

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//蛇的身体数组
@property (nonatomic,strong) NSMutableArray *snakeBodyArray;

//蛇的方向数组---对应每个部分下次移动的方向
@property (nonatomic,strong) NSMutableArray *snakeBodyDirectionArray;

//棋盘数组
@property (nonatomic,strong) NSMutableArray *sqrDataArray;

@property (nonatomic,strong) UIImageView *myBackgroundView;

@property (nonatomic,strong) UIButton *upBtn;

@property (nonatomic,strong) UIButton *downBtn;

@property (nonatomic,strong) UIButton *leftBtn;

@property (nonatomic,strong) UIButton *rightBtn;

@property (nonatomic,strong) UIButton *pauseBtn;        //暂停

@property (nonatomic,strong) UIButton *reStartBtn;      //重启

//蛇的当前移动状态
typedef enum {
    snakeGoUp = 1,  //向上
    snakeGoDown,    //向下
    snakeGoLeft,    //向左
    snakeGoRight    //向右
} snakeMoveDirection;

@property (nonatomic,assign) NSInteger snakeMoveDirection;

//计时器
@property (nonatomic,strong) NSTimer *snakeTimer;

//蛋
@property (nonatomic,assign) NSInteger snakeEgg;

//速度状态
typedef enum {
    oldMan = 1,
    elf = 2,
    soExcite = 3,
    oldDriver = 4,
    godLike = 5,
    secretEgg = 6
    
} snakeSpeedStatus;
@property (nonatomic,assign) NSInteger snakeSpeedStatus;

@property (nonatomic,strong) UIButton *increaseSpeedBtn;

@property (nonatomic,strong) UIButton *reduceSpeedBtn;

@property (nonatomic,strong) UILabel *snakeSpeedLab;


@property (nonatomic,strong) UIImagePickerController *imagePicker; //相机相关

@property (nonatomic,strong) UILabel *scoreLabel;       //计分板

@property (nonatomic,assign) NSInteger myScore;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //UI包括4个按钮，主要界面
    [self createUI];
    
    //数据初始化/读取之前的保存记录
    [self createData];
    
}

- (void)createUI {
    
//    self.view.backgroundColor = [UIColor colorWithRed:223/255.f green:255/255.f blue:214/255.f alpha:1];
    
    [self.view addSubview:self.myBackgroundView];
    self.myBackgroundView.frame = CGRectMake(0, 0, sqrHeight*15, sqrHeight*20);
    self.myBackgroundView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-80);
    
    [self initTheSquear];
    
    [self.view addSubview:self.pauseBtn];
    self.pauseBtn.center = CGPointMake(40, 550);
    
    [self.view addSubview:self.reStartBtn];
    self.reStartBtn.center = CGPointMake(120, 550);
    
    [self.view addSubview:self.upBtn];
    self.upBtn.center = CGPointMake(280, 530);
    
    [self.view addSubview:self.downBtn];
    self.downBtn.center = CGPointMake(280, 630);
    
    [self.view addSubview:self.leftBtn];
    self.leftBtn.center = CGPointMake(230, 580);
    
    [self.view addSubview:self.rightBtn];
    self.rightBtn.center = CGPointMake(330, 580);
    
    [self.view addSubview:self.increaseSpeedBtn];
    self.increaseSpeedBtn.center = CGPointMake(40, 640);
    
    [self.view addSubview:self.snakeSpeedLab];
    self.snakeSpeedLab.center = CGPointMake(120, 640);
    
    [self.view addSubview:self.reduceSpeedBtn];
    self.reduceSpeedBtn.center = CGPointMake(200, 640);
    
    [self.view addSubview:self.scoreLabel];
    self.scoreLabel.center = CGPointMake(self.view.bounds.size.width/2, 490);
}

//初始化游戏界面，画格子
- (void)initTheSquear {
    
    self.sqrDataArray = [[NSMutableArray alloc] init];
    
    for (NSInteger j = 0; j < 20; j++) {
        for (NSInteger i = 0; i < 15; i++) {
            
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0+i*sqrHeight, 0+(j*sqrHeight), sqrHeight, sqrHeight);
            label.layer.borderWidth = 0.5;
            label.layer.borderColor = [[UIColor colorWithRed:arc4random()%255/255.f green:arc4random()%255/255.f blue:arc4random()%255/255.f alpha:1] CGColor];
            label.tag = 1000+(i+(j*15));
//            label.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.f green:arc4random()%255/255.f blue:arc4random()%255/255.f alpha:1];
            label.backgroundColor = [UIColor clearColor];
//            label.adjustsFontSizeToFitWidth = YES;
//            label.text = [NSString stringWithFormat:@"%ld",(long)label.tag-1000];
            
            [self.myBackgroundView addSubview:label];
            [self.sqrDataArray addObject:label];
        }
    }
    
}

- (void)createData {
    
    //纵向初始化(向上)
    self.snakeBodyArray = [[NSMutableArray alloc] initWithObjects:@"112",@"127",@"142",@"157",@"172",nil];
    self.snakeBodyDirectionArray = [[NSMutableArray alloc] initWithObjects:@"1",@"1",@"1",@"1",@"1",nil];
    
    //横向初始化(向左)
//    self.snakeBodyArray = [[NSMutableArray alloc] initWithObjects:@"155",@"156",@"157",@"158",@"159",nil];
//    self.snakeBodyDirectionArray = [[NSMutableArray alloc] initWithObjects:@"3",@"3",@"3",@"3",@"3",nil];

    //得分清零
    self.myScore = 0;
    [self showScoreLabel];
    
    self.snakeSpeedStatus = oldMan;
    float timeInterval = 1/self.snakeSpeedStatus;
    
    self.snakeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(smartBrain) userInfo:nil repeats:YES];
    [self.snakeTimer setFireDate:[NSDate distantFuture]];
    [self showSnakeSpeedStatusLab];
    
    [self snakeMoveAnime];
    
    [self makeEgg];
}

#pragma mark -懒加载-
- (UIImageView *)myBackgroundView {
    
    if (!_myBackgroundView) {
        
        _myBackgroundView = [[UIImageView alloc] init];
        _myBackgroundView.backgroundColor = [UIColor whiteColor];
        _myBackgroundView.layer.borderWidth = 1;
        _myBackgroundView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tap.numberOfTapsRequired = 2;
        [_myBackgroundView addGestureRecognizer:tap];
        
    }
    return _myBackgroundView;
}

- (UIButton *)upBtn {
    
    if (!_upBtn) {
        _upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _upBtn.frame = CGRectMake(0, 0, btnHeight, btnHeight);
        _upBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _upBtn.layer.cornerRadius = btnHeight/2;
        [_upBtn setTitle:@"↑" forState:UIControlStateNormal];
        [_upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_upBtn addTarget:self action:@selector(upBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _upBtn;
}

- (UIButton *)downBtn {
    
    if (!_downBtn) {
        _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _downBtn.frame = CGRectMake(0, 0, btnHeight, btnHeight);
        _downBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _downBtn.layer.cornerRadius = btnHeight/2;
        [_downBtn setTitle:@"↓" forState:UIControlStateNormal];
        [_downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_downBtn addTarget:self action:@selector(downBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _downBtn;
}

- (UIButton *)leftBtn {
    
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(0, 0, btnHeight, btnHeight);
        _leftBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _leftBtn.layer.cornerRadius = btnHeight/2;
        [_leftBtn setTitle:@"←" forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 0, btnHeight, btnHeight);
        _rightBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _rightBtn.layer.cornerRadius = btnHeight/2;
        [_rightBtn setTitle:@"→" forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _rightBtn;
}

- (UIButton *)pauseBtn {
    
    if (!_pauseBtn) {
        
        _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pauseBtn.frame = CGRectMake(0, 0, btnHeight, btnHeight);
        _pauseBtn.layer.cornerRadius = btnHeight/2;
        _pauseBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _pauseBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_pauseBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_pauseBtn setTitle:@"暂停" forState:UIControlStateSelected];
        [_pauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_pauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_pauseBtn addTarget:self action:@selector(pauseBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _pauseBtn;
}

- (UIButton *)reStartBtn {
    
    if (!_reStartBtn) {
        
        _reStartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reStartBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _reStartBtn.frame = CGRectMake(0, 0, btnHeight, btnHeight);
        _reStartBtn.layer.cornerRadius = btnHeight/2;
        _reStartBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_reStartBtn setTitle:@"重启" forState:UIControlStateNormal];
        [_reStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_reStartBtn addTarget:self action:@selector(reStartBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _reStartBtn;
}

- (UIButton *)increaseSpeedBtn {
    
    if (!_increaseSpeedBtn) {
        
        _increaseSpeedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _increaseSpeedBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _increaseSpeedBtn.frame = CGRectMake(0, 0, 40, 30);
        [_increaseSpeedBtn setTitle:@"＋" forState:UIControlStateNormal];
        [_increaseSpeedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_increaseSpeedBtn addTarget:self action:@selector(increaseSpeedBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _increaseSpeedBtn;
}

- (UIButton *)reduceSpeedBtn {
    
    if (!_reduceSpeedBtn) {
        
        _reduceSpeedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _reduceSpeedBtn.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:1 alpha:1];
        _reduceSpeedBtn.frame = CGRectMake(0, 0, 40, 30);
        [_reduceSpeedBtn setTitle:@"－" forState:UIControlStateNormal];
        [_reduceSpeedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_reduceSpeedBtn addTarget:self action:@selector(reduceSpeedBtnAction) forControlEvents:UIControlEventTouchDown];
    }
    return _reduceSpeedBtn;
}
//码速表
- (UILabel *)snakeSpeedLab {
    
    if (!_snakeSpeedLab) {
        
        _snakeSpeedLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        _snakeSpeedLab.adjustsFontSizeToFitWidth = YES;
        _snakeSpeedLab.textAlignment = NSTextAlignmentCenter;
        _snakeSpeedLab.layer.borderWidth = 0.5;
        _snakeSpeedLab.layer.borderColor = [UIColor blackColor].CGColor;
        _snakeSpeedLab.layer.cornerRadius = 5;
    }
    return _snakeSpeedLab;
}

//计分板
- (UILabel *)scoreLabel {
    
    if (!_scoreLabel) {
        
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 50)];
//        _scoreLabel.backgroundColor = [UIColor blueColor];
        _scoreLabel.adjustsFontSizeToFitWidth = YES;
        _scoreLabel.textAlignment = NSTextAlignmentCenter;
        _scoreLabel.layer.borderWidth = 0.5;
        _scoreLabel.layer.borderColor = [UIColor blackColor].CGColor;
        _scoreLabel.layer.cornerRadius = 5;
        
        [_scoreLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
    }
    return _scoreLabel;
}

#pragma mark -上下左右点击事件-
- (void)upBtnAction {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.snakeBodyDirectionArray[0] isEqualToString:@"2"]) {
        return;
    }
    
    self.snakeMoveDirection = snakeGoUp;
    [self.snakeBodyDirectionArray setObject:@"1" atIndexedSubscript:0];

}

- (void)downBtnAction {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.snakeBodyDirectionArray[0] isEqualToString:@"1"]) {
        return;
    }
    
    self.snakeMoveDirection = snakeGoDown;
    [self.snakeBodyDirectionArray setObject:@"2" atIndexedSubscript:0];
    
}

- (void)leftBtnAction {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.snakeBodyDirectionArray[0] isEqualToString:@"4"]) {
        return;
    }
    
    self.snakeMoveDirection = snakeGoLeft;
    [self.snakeBodyDirectionArray setObject:@"3" atIndexedSubscript:0];
    
}

- (void)rightBtnAction {

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.snakeBodyDirectionArray[0] isEqualToString:@"3"]) {
        return;
    }
    
    self.snakeMoveDirection = snakeGoRight;
    [self.snakeBodyDirectionArray setObject:@"4" atIndexedSubscript:0];

}

//暂停/开始
- (void)pauseBtnAction {

    _pauseBtn.selected = !_pauseBtn.selected;
    if (_pauseBtn.selected) {
        
        [self.snakeTimer setFireDate:[NSDate date]];
    }
    else {
        
        [self.snakeTimer setFireDate:[NSDate distantFuture]];
        
    }
}

//重置
- (void)reStartBtnAction {
    
    if (!_pauseBtn.selected) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您确定要重新开始游戏么？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self clearEgg];
            [self clearTheMove];
            [self createData];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
}

//加速
- (void)increaseSpeedBtnAction {
    
    if (self.snakeSpeedStatus == 5) {
        return;
    }
    self.snakeSpeedStatus++;
    
    [self.snakeTimer invalidate];
    float timeInterval = 0.0;
    switch (self.snakeSpeedStatus) {
        case 2:{
            timeInterval = 0.5;
        }break;
        case 3:{
            timeInterval = 0.33;
        }break;
        case 4:{
            timeInterval = 0.25;
        }break;
        case 5:{
            timeInterval = 0.2;
        }break;
        default:
            break;
    }
    self.snakeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(smartBrain) userInfo:nil repeats:YES];
    if (self.pauseBtn.selected) {
        [self.snakeTimer setFireDate:[NSDate date]];
    }
    else {
        [self.snakeTimer setFireDate:[NSDate distantFuture]];
    }
    
    [self showSnakeSpeedStatusLab];
}

//减速
- (void)reduceSpeedBtnAction {
    
    if (self.snakeSpeedStatus == 1) {
        return;
    }
    self.snakeSpeedStatus--;
    
    [self.snakeTimer invalidate];
    float timeInterval = 0.0;
    switch (self.snakeSpeedStatus) {
        case 1:{
            timeInterval = 1;
        }break;
        case 2:{
            timeInterval = 0.5;
        }break;
        case 3:{
            timeInterval = 0.33;
        }break;
        case 4:{
            timeInterval = 0.25;
        }break;
        default:
            break;
    }
    self.snakeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(smartBrain) userInfo:nil repeats:YES];
    if (self.pauseBtn.selected) {
        [self.snakeTimer setFireDate:[NSDate date]];
    }
    else {
        [self.snakeTimer setFireDate:[NSDate distantFuture]];
    }
    
    [self showSnakeSpeedStatusLab];
}

//show码速表
- (void)showSnakeSpeedStatusLab {
    
    switch (self.snakeSpeedStatus) {
        case 1:{
            self.snakeSpeedLab.text = @"电竞养老院选手";
        }break;
        case 2:{
            self.snakeSpeedLab.text = @"踩了一jo香蕉皮";
        }break;
        case 3:{
            self.snakeSpeedLab.text = @"骑士给个自由";
        }break;
        case 4:{
            self.snakeSpeedLab.text = @"AE86上山了";
        }break;
        case 5:{
            self.snakeSpeedLab.text = @"GodLike";
        }break;
        default:
            break;
    }
    
}

//彩蛋触发
- (void)secretEggAction {
    
    self.snakeSpeedStatus = secretEgg;
    
    self.snakeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(smartBrain) userInfo:nil repeats:YES];
    [self.snakeTimer setFireDate:[NSDate date]];
    
    self.increaseSpeedBtn.enabled = NO;
    self.reduceSpeedBtn.enabled = NO;
    
    self.snakeSpeedLab.text = @"1337";
}

#pragma mark -行动函数-
- (void)smartBrain {

    [self clearTheMove];
    
    
    NSMutableArray *snakeNewBody = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.snakeBodyDirectionArray.count; i++) {
        
        NSString *directStr = self.snakeBodyDirectionArray[i];
        NSString *oldBodyStr = self.snakeBodyArray[i];
        
        switch ([directStr integerValue]) {
            case 1:{
                //上触碰检测
                NSInteger oldIndex = [oldBodyStr integerValue];
                if (oldIndex-15 < 0) {
                    [self AlertUser];
                    return;
                }
                
                [snakeNewBody addObject:[NSString stringWithFormat:@"%ld",oldIndex-15]];
                
            }break;
            case 2:{
                //下触碰检测
                NSInteger oldIndex = [oldBodyStr integerValue];
                if (oldIndex+15 >= 300) {
                    [self AlertUser];
                    return;
                }
                
                [snakeNewBody addObject:[NSString stringWithFormat:@"%ld",oldIndex+15]];
                
            }break;
            case 3:{
                //触碰左边界检测
                NSInteger oldIndex = [oldBodyStr integerValue];
                if (oldIndex%15 == 0) {
                    [self AlertUser];
                    return;
                }

                [snakeNewBody addObject:[NSString stringWithFormat:@"%ld",oldIndex-1]];
                
            }break;
            case 4:{
                //触碰右边界检测
                NSInteger oldIndex = [oldBodyStr integerValue];
                if (oldIndex%15 == 14) {
                    [self AlertUser];
                    return;
                }
                
                [snakeNewBody addObject:[NSString stringWithFormat:@"%ld",oldIndex+1]];

            }break;
            default:
                break;
        }
        
    }
    
    //吃掉蛋
    if ([snakeNewBody[0] integerValue] == _snakeEgg) {
        
        [snakeNewBody addObject:[self.snakeBodyArray lastObject]];
        
        [self makeScore];
        
        NSString *newDirection = [self.snakeBodyDirectionArray lastObject];
        [self.snakeBodyDirectionArray addObject:newDirection];
        [self makeEgg];
    }
    
    //更新蛇的身体
    self.snakeBodyArray = snakeNewBody;
    
    //自身身体碰撞检测
    for (NSInteger i = 1; i < self.snakeBodyArray.count; i++) {
        NSString *body = self.snakeBodyArray[i];
        if ([body isEqualToString:self.snakeBodyArray[0]]) {
            [self AlertUser];
            return;
        }
    }
    
    [self snakeMoveAnime];
    
    //蛇身体方向数组修改
    NSMutableArray *newSnakeBodyDirectionArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.snakeBodyDirectionArray.count; i++) {
        
        if (!i) {
            [newSnakeBodyDirectionArray addObject:[self.snakeBodyDirectionArray firstObject]];
        }
        else {
            NSString *beforeStr = self.snakeBodyDirectionArray[i-1];
            NSString *afterStr = self.snakeBodyDirectionArray[i];
            
            if (![beforeStr isEqualToString:afterStr]) {
                [newSnakeBodyDirectionArray addObject:beforeStr];
            }
            else {
                [newSnakeBodyDirectionArray addObject:afterStr];
            }

        }
    }
    self.snakeBodyDirectionArray = newSnakeBodyDirectionArray;

}

//生成一个蛋
- (void)makeEgg {
    
    NSInteger _eggNum = arc4random()%300;
    
    if (![self checkEggWithEgg:_eggNum]) {
        
        [self.snakeTimer setFireDate:[NSDate distantFuture]];
        //触发彩蛋
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你触发了一个彩蛋" message:@"作者将赐予你一双黄油鞋,你将获得无与伦比的速度!请开始你的表演~" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"准备就绪！" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self secretEggAction];
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        //再生成一个蛋
        [self makeEgg];
    }
    else {
        [self showEggWithEgg:_eggNum];
    }
    
}

//检测蛋是否合格
- (BOOL)checkEggWithEgg:(NSInteger )egg {
        
    for (NSString *string in self.snakeBodyArray) {
        if (egg == [string integerValue]) {
            return NO;
        }
    }
    return YES;
}

//展示蛋
- (void)showEggWithEgg:(NSInteger )egg {
    
    _snakeEgg = egg;
    UILabel *label = self.sqrDataArray[egg];
    label.backgroundColor = [UIColor colorWithRed:255.f green:255.f blue:0.f alpha:1];
}

//清除屏幕上的蛋
- (void)clearEgg {
    
    UILabel *label = self.sqrDataArray[_snakeEgg];
    label.backgroundColor = [UIColor clearColor];
}

//记分
- (void)makeScore {
    
    NSInteger _baseScore = 10;
    
    switch (self.snakeSpeedStatus) {
        case 1:{
            _baseScore = _baseScore*1;
        }break;
        case 2:{
            _baseScore = _baseScore*2;
        }break;
        case 3:{
            _baseScore = _baseScore*3;
        }break;
        case 4:{
            _baseScore = _baseScore*4;
        }break;
        case 5:{
            _baseScore = _baseScore*5;
        }break;
        case 6:{
            _baseScore = _baseScore*10;
        }break;
        default:
            break;
    }
    
    self.myScore = self.myScore + _baseScore;
    
    [self showScoreLabel];
}

//刷新计分板
- (void)showScoreLabel {
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld",(long)self.myScore];
}


//清空原有动画
- (void)clearTheMove {
    for (NSString *string in self.snakeBodyArray) {
        NSInteger index = [string integerValue];
        if (index > 300 || index < 0) {
            continue;
        }
        UILabel *label = self.sqrDataArray[index];
        label.backgroundColor = [UIColor clearColor];
    }
}

//执行动画
- (void)snakeMoveAnime {
    
    for (NSString *string in self.snakeBodyArray) {
        NSInteger index = [string integerValue];
        UILabel *label = self.sqrDataArray[index];
        label.backgroundColor = [UIColor blackColor];
    }
}

//弹窗警告
- (void)AlertUser {
    
    _pauseBtn.selected = NO;
    [self.snakeTimer setFireDate:[NSDate distantFuture]];
    [self clearEgg];
    self.increaseSpeedBtn.enabled = YES;
    self.reduceSpeedBtn.enabled = YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"你死了,最终得分:%ld",(long)_myScore] message:@"点击确定，再来一次！" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self clearTheMove];
        [self createData];
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


#pragma mark - 换背景方法 -
//调用相机或者相册
- (void)tapAction {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *normal = [UIAlertAction actionWithTitle:@"默认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _myBackgroundView.backgroundColor = [UIColor whiteColor];
        for (UILabel *label in self.sqrDataArray) {
            label.backgroundColor = [UIColor clearColor];
        }
    }];
    
    UIAlertAction *colorFul = [UIAlertAction actionWithTitle:@"五彩斑斓的黑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UILabel *label in self.sqrDataArray) {
            label.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.f green:arc4random()%255/255.f blue:arc4random()%255/255.f alpha:1];
        }
    }];
    
    UIAlertAction *canmera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImageFromCamera];
    }];
    
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImageFromAlbum];
    }];
    
    [alertController addAction:cancel];
//    [alertController addAction:normal];
//    [alertController addAction:colorFul];
    [alertController addAction:canmera];
    [alertController addAction:photo];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

//从相机选择的方法
- (void)pickImageFromCamera {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:^{
    }];
}

//从相册选择的方法
- (void)pickImageFromAlbum {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:^{
    }];
}

#pragma mark - 从相机相册回调选择的协议方法 -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
    
    UIImage *beforeImg = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //同时写入相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(beforeImg,self,nil,nil);
    }
    
    self.myBackgroundView.image = beforeImg;
}






- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"]) {
       
        NSInteger _nowScore = [change[@"new"] integerValue];
        if (_nowScore >= 1000 && self.snakeSpeedStatus < 5) {
            [self increaseSpeedBtnAction];
        }
        else if (_nowScore >= 800 && self.snakeSpeedStatus < 4) {
            [self increaseSpeedBtnAction];
        }
        else if (_nowScore >= 400 && self.snakeSpeedStatus < 3) {
            [self increaseSpeedBtnAction];
        }
        else if (_nowScore >= 100 && self.snakeSpeedStatus < 2) {
            [self increaseSpeedBtnAction];
        }
        
    }
}

- (void)dealloc {
    [self.snakeTimer invalidate];
    self.snakeTimer = nil;
    
    [self.scoreLabel removeObserver:self forKeyPath:@"text"];
}


#pragma mark - 以下方法为早期开发思路，先弃用 -
//上行平移函数
- (void)upMove {
    
    NSMutableArray *newSnakeBodyArray = [[NSMutableArray alloc] init];
    
    for (NSString *string in self.snakeBodyArray) {
        
        NSInteger oldIndex = [string integerValue];
        [newSnakeBodyArray addObject:[NSString stringWithFormat:@"%ld",(long)oldIndex-15]];
        
        if (oldIndex-15 < 0) {
            [self AlertUser];
            return;
        }
    }
    
    self.snakeBodyArray = newSnakeBodyArray;
}

//下行平移函数
- (void)downMove {
    
    NSMutableArray *newSnakeBodyArray = [[NSMutableArray alloc] init];
    
    for (NSString *string in self.snakeBodyArray) {
        
        NSInteger oldIndex = [string integerValue];
        [newSnakeBodyArray addObject:[NSString stringWithFormat:@"%ld",(long)oldIndex+15]];
        
        if (oldIndex+15 > 300) {
            [self AlertUser];
            return;
        }
    }
    
    self.snakeBodyArray = newSnakeBodyArray;
}

//左行平移函数
- (void)leftMove {
    
    NSMutableArray *newSnakeBodyArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.snakeBodyArray.count; i++) {
        NSString *string = self.snakeBodyArray[i];
        NSInteger oldIndex = [string integerValue];
        [newSnakeBodyArray addObject:[NSString stringWithFormat:@"%ld",(long)oldIndex-1]];
        
        //触碰左边界
        if (oldIndex%15 == 0) {
            if (oldIndex - (oldIndex-1) == 1) {
                [self AlertUser];
                return;
            }
        }
    }
    
    self.snakeBodyArray = newSnakeBodyArray;
}

//右行平移函数
- (void)rightMove {
    
    NSMutableArray *newSnakeBodyArray = [[NSMutableArray alloc] init];
    
    for (NSString *string in self.snakeBodyArray) {
        NSInteger oldIndex = [string integerValue];
        [newSnakeBodyArray addObject:[NSString stringWithFormat:@"%ld",(long)oldIndex+1]];
        
        //触碰左边界
        if (oldIndex%15 == 14) {
            if ((oldIndex+1)-oldIndex == 1) {
                [self AlertUser];
                return;
            }
        }
        
    }
    
    self.snakeBodyArray = newSnakeBodyArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
