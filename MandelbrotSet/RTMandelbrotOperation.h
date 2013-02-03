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
@end


@interface RTMandelbrotOperation : NSOperation
@property  CGRect bounds;
@property (strong) UIImage* result;
@property  float currScaleFactor;
@property RTPoint center;
@property CGPoint screenCenter;
@property (strong) NSArray* colorTable;
@property (strong) UIProgressView* progress;
@property (strong) UILabel* progressLabel;
@property (weak) id <RTMandelbrotOperationDelegate> delegate;
@property int maxIterations;

- (id)initWithBounds:(CGRect)newBounds retina:(BOOL)ret;

- (long double)scaleX:(CGFloat)screenCoord;
- (long double)scaleY:(CGFloat)screenCoord;
@end

inline RTPoint RTPointMake(long double x, long double y)
{
    RTPoint point;
    point.x = x;
    point.y = y;
    return point;
}