//
//  RTMandelbrotOperation.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/24/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTMandelbrotOperationDelegate
- (void)dismissProgress;
@end


@interface RTMandelbrotOperation : NSOperation
@property  CGRect bounds;
@property (strong) UIImage* result;
@property  float currScaleFactor;
@property CGPoint center;
@property CGPoint screenCenter;
@property (strong) NSArray* colorTable;
@property (strong) UIProgressView* progress;
@property (strong) UILabel* progressLabel;
@property (weak) id <RTMandelbrotOperationDelegate> delegate;
@property int maxIterations;

- (id)initWithBounds:(CGRect)newBounds retina:(BOOL)ret;

- (float)scaleX:(CGFloat)screenCoord;
- (float)scaleY:(CGFloat)screenCoord;
@end