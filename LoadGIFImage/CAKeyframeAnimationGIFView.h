//
//  CAKeyframeAnimationGIFView.h
//  LoadGIFImage
//
//  Created by 杜文亮 on 2018/5/24.
//  Copyright © 2018年 心动文学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAKeyframeAnimationGIFView : UIView

@property (nonatomic,assign,readonly) BOOL isAnimating;

-(instancetype)initWithCAKeyframeAnimationWithPath:(NSString *)path;

-(void)startGIF;
-(void)stopGIF;

@end

