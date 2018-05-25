//
//  ViewController.m
//  LoadGIFImage
//
//  Created by 杜文亮 on 2018/5/22.
//  Copyright © 2018年 心动文学. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+GIF.h"
#import "UIImageView+WebCache.h"
#import "TimerGifView.h"
#import "CAKeyframeAnimationGIFView.h"


@interface ViewController ()

@property (nonatomic,strong) UIImageView *imgView;

@end


@implementation ViewController

-(UIImageView *)imgView
{
    if (!_imgView)
    {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        _imgView.center = self.view.center;
        _imgView.backgroundColor = [UIColor greenColor];
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

//常用的UIImageView是无法直接加载GIF图片的（但是依然可以通过[UIImage imageNamed:@"1.gif"]来获取图片对象，可以进一步获得图片的size等信息）
-(void)loadGIFWithImgViewDirectly
{
    self.imgView.image = [UIImage imageNamed:@"1.gif"];
    NSLog(@"原始图片信息：%@",_imgView.image);
}




#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self loadGIFWithImgViewDirectly];
    
    /*
     *                         加载本地GIF图片
        - 1.1、1.2方便快捷，不能控制开始和结束，仅仅用于播放展示（只能在旁边看它表演）。
        - 2.1可以控制开始和结束（2.2不可以），但是若GIF动画间隔不一样，效果会和原图不一致（这里是等间隔的）
        - 3本质上和2.2一样
     
        - 2.1、2.2、3都可以通过下面的控制方法实现暂停、继续播放，2.1另外还能控制开始、结束
     
        常用的是2.1、2.2（3）
     */
    
    //方式1
//    [self loadGIFWithWebView1];
//    [self loadGIFWithWebView2];
    
    //方式2
//    [self loadGIFWithImgView1];
//    [self loadGIFWithImgView2];

    //方式3
//    [self loadGIFWithSDWebImage];
    
    //方式4
//    TimerGifView *view = [[TimerGifView alloc] initWithGIFPath:[[NSBundle mainBundle] pathForResource:@"1@3x" ofType:@"gif"]];
//    view.frame = CGRectMake(0, 0, 300, 300);
//    view.center = self.view.center;
//    [self.view addSubview:view];
//    if (!view.isAnimating)
//    {
//        [view startGIF];
//    }
    CAKeyframeAnimationGIFView *view = [[CAKeyframeAnimationGIFView alloc] initWithCAKeyframeAnimationWithPath:[[NSBundle mainBundle] pathForResource:@"1@3x" ofType:@"gif"]];
    view.frame = CGRectMake(0, 0, 300, 300);
    view.center = self.view.center;
    [self.view addSubview:view];
    if (!view.isAnimating)
    {
        [view startGIF];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        if (view.isAnimating)
        {
            [view stopGIF];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            if (!view.isAnimating)
            {
                [view startGIF];
            }
        });
    });
}


#pragma mark - 1，通过UIWebView进行加载

//1.1，若有Nav，iOS8下图片会距离webView顶部64，iOS9之后不会有。无Nav，iOS8以后显示都一样
-(void)loadGIFWithWebView1
{
    //通过bundle加载资源文件的方式，必须将文件名写全
    NSData *gif = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1@3x" ofType:@"gif"]];
    NSLog(@"image data:%@",gif);//主要指图片，倍图要写xxx@2x，否则无效

    //webView跟imgView不同。若图片超出控件frame，后者会自动让图片适应在frame内，前者不会
    UIImage *img = [UIImage imageNamed:@"1.gif"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    [webView setCenter:self.view.center];
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:@"UTF-8" baseURL:[NSURL fileURLWithPath:@""]];
    //即便图片size和webView的frame一样，也不会自适应在frame内，除非设置scalesPageToFit
    webView.scalesPageToFit = YES;
//    webView.userInteractionEnabled = NO;
    [self.view addSubview:webView];
}
//1.2，做成本地网页进行加载
-(void)loadGIFWithWebView2
{
    NSURL *resourceUrl = [NSBundle mainBundle].resourceURL;
    NSString *html = [NSString stringWithFormat:@"<html><body><img src=\"%@.%@\"></body></html>", @"1@3x", @"gif"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    webView.center = self.view.center;
    webView.scalesPageToFit = YES;
    [webView loadHTMLString:html baseURL:resourceUrl];
    [self.view addSubview:webView];

}


#pragma mark - 2，使用UIImageView展示（将gif图片分解成多张png图片放入工程中）

//2.1，使用UIImageView播放
-(void)loadGIFWithImgView1
{
    NSArray *image_arr = [NSArray arrayWithObjects:[UIImage imageNamed:@"3"],[UIImage imageNamed:@"4"],[UIImage imageNamed:@"5"], nil];
    self.imgView.animationImages = image_arr;
    self.imgView.animationDuration = 5;
    self.imgView.animationRepeatCount = 5;
    [self.imgView startAnimating];
    
    //暂停和继续播放
    [self pauseAndResumeControl];
    
    //结束和开始播放
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
//    {
//        [self.imgView stopAnimating];
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
//        {
//            [self.imgView startAnimating];
//        });
//    });
}
//2.2，做成动态的Image对象，用UIImageView展示(3中的底层实现也是这样)
-(void)loadGIFWithImgView2
{
    UIImage *img = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"3"],[UIImage imageNamed:@"4"],[UIImage imageNamed:@"5"]] duration:5.0];
    self.imgView.image = img;
    
    //暂停和继续播放
    [self pauseAndResumeControl];
}


#pragma mark - 3，SDWebImage展示GIF

//3，SDWebImage(本质和2.2一样，是SDWebImage对2.2的封装，但是2.2需要我们自己分解图片，并且构造动态Image，而这里直接使用GIF图片即可，更加方便)
-(void)loadGIFWithSDWebImage
{
    NSData *gif = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1@3x" ofType:@"gif"]];
    UIImage *img = [UIImage sd_animatedGIFWithData:gif];
    self.imgView.image = img;
    
    //暂停和继续播放
    [self pauseAndResumeControl];
}




#pragma mark - 手动实现暂停、继续  控制方法(本质是对layer动画的控制，对于2、3适用)

//模拟继续、暂停的控制方法
-(void)pauseAndResumeControl
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
   {
       [self pauseLayer:self.imgView.layer];
       
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
      {
          [self resumeLayer:self.imgView.layer];
      });
   });
}

//暂停gif的方法
-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续gif的方法
-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}


@end
