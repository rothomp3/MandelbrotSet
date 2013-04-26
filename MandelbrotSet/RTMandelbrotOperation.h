//
//  RTMandelbrotOperation.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/24/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _RTPoint
{
    long double x;
    long double y;
} RTPoint;

@protocol RTMandelbrotOperationDelegate
- (void)dismissProgress;
- (void)updateImage:(UIImage*)newImage;
@end

@class RTColorTable;

@interface RTMandelbrotOperation : NSOperation
@property  CGRect bounds;
@property (strong) UIImage* result;
@property  float currScaleFactor;
@property RTPoint center;
@property CGPoint screenCenter;
@property (strong) RTColorTable* colorTable;

@property (weak) id <RTMandelbrotOperationDelegate> delegate;
@property int maxIterations;

@property (strong) NSTimer* progressTimer;
@property size_t totalBitmapSize;
@property __block CGContextRef context;

- (id)initWithBounds:(CGRect)newBounds retina:(BOOL)ret;

- (long double)scaleX:(CGFloat)screenCoord;
- (long double)scaleY:(CGFloat)screenCoord;

- (void)updateProgress:(NSTimer*)timer;
@end

#ifndef DEBUG
inline RTPoint RTPointMake(long double x, long double y)
{
    RTPoint point;
    point.x = x;
    point.y = y;
    return point;
}

inline long double scale_x(CGFloat screenCoord, CGPoint screenCenter, long double currScaleFactor, RTPoint center)
{
    return ((long double)screenCoord - (long double)(screenCenter.x))/currScaleFactor + (long double)(center.x);
}

inline long double scale_y(CGFloat screenCoord, CGPoint screenCenter, long double currScaleFactor, RTPoint center)
{
    return (0.0l - ((long double)screenCoord - (long double)(screenCenter.y)))/currScaleFactor + (long double)(center.y);
}
#else
RTPoint RTPointMake(long double x, long double y);
long double scale_x(CGFloat screenCoord, CGPoint screenCenter, long double currScaleFactor, RTPoint center);
long double scale_y(CGFloat screenCoord, CGPoint screenCenter, long double currScaleFactor, RTPoint center);
#endif