//
//  RTMandelbrotOperation.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/24/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTMandelbrotOperation.h"
#include <complex.h>
#import "RTColorTable.h"

void printBits(unsigned int num)
{
    for(int bit=0;bit<(sizeof(unsigned int) * 8); bit++)
    {
        printf("%i ", num & 0x01);
        num = num >> 1;
    }
}

@implementation RTMandelbrotOperation
@synthesize bounds, currScaleFactor, center, screenCenter, totalBitmapSize, context;
- (id)init
{
    return [self initWithBounds:[[UIScreen mainScreen] bounds] retina:!((int)([UIScreen mainScreen].scale) % 2)];
}

- (id)initWithBounds:(CGRect)newBounds retina:(BOOL)ret
{
    self = [super init];
    if (self)
    {
        CGRect retinaBounds;
        if (ret)
        {
            retinaBounds.origin = newBounds.origin;
            retinaBounds.size.height = newBounds.size.height * 2.0f;
            retinaBounds.size.width = newBounds.size.width * 2.0f;
            currScaleFactor = 100.0f;
        }
        else
        {
            retinaBounds = newBounds;
            currScaleFactor = 50.0f;
        }
        [self setBounds:retinaBounds];
        center.x = -1.0f;
        center.y = 0.0f;
    }
    return self;
}

- (void)updateProgress:(NSTimer *)timer
{
    CGImageRef tempImage = CGBitmapContextCreateImage(context);
    self.result = [UIImage imageWithCGImage:tempImage];
    CGImageRelease(tempImage);
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.delegate updateImage:self.result];
    } );
}

- (void)main
{
    size_t bitmapBytesPerRow = bounds.size.width * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    
    screenCenter.x = bounds.size.width / 2.0f;
    screenCenter.y = bounds.size.height / 2.0f;
    
    long double iterationMagnitude = log10l(self.maxIterations) * 6.43f;
    
    totalBitmapSize = bounds.size.width * bounds.size.height;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    uint8_t* bitmapPtr = calloc(totalBitmapSize*4, sizeof(uint8_t));//malloc(sizeof(uint8_t) * totalBitmapSize * 4);

    context = CGBitmapContextCreate(bitmapPtr, bounds.size.width, bounds.size.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetAllowsAntialiasing(context, true);
    
    int maxIterations = self.maxIterations;
    
    int numColors = self.colorTable.numColors;
    RTColor* colorTable = self.colorTable.colors;
    
    void (^mandelthing)(size_t i) = ^(size_t i)
    {
        if ([self isCancelled])
            return;
        void (^innerMandelthing)(size_t j) = ^(size_t j)
        {
            if ([self isCancelled])
                return;
            // first we get the correctly scaled (x,y) point c
            long double x = scale_x(i, screenCenter, currScaleFactor, center);
            long double y = scale_y(j, screenCenter, currScaleFactor, center);
            //complex long double c = x + y*I;
            
            // Nothing fails after zero iterations…
            int k = 1;
            

            complex long double z = 0.0f;
            
            // only do these calculations once
            long double y2 = y * y; // imaginary part of c, squared
            long double x2 = x * x; // real part of c, squared
            
            // next two lines are for checking the main cardioid
            long double q = x2 - (0.5l * x) + 0.0625l + y2;
            //long double r = q * (q + (x - 0.25l));
            
            if ((x2 + x + x + 1.0l + y2 < 0.0625l) || (q * (q + (x - 0.25l)) < (0.25l * y2))) // inside the period-2 bulb or main carioid
            {
                k = maxIterations;
                z = x + y*I;
            }
            
            // These variables are setup for the period checking
            int check = 3;
            int checkCounter = 0;
            int update = 10;
            int updateCounter = 0;
            long double hx = 0.0l;
            long double hy = 0.0l;
        
            long double zr = 0.0l;
            long double zi = 0.0l;
            while ((k < maxIterations))
            {
                // Check for bailout at radius 2
                if (zr*zr + zi*zi >= 4.0l)
                {
                    break;
                }
                
                // Do the Mandelbrot (/dance)
                z = (z * z) + (x + y*I);

                //zr = creall(z);
                //zi = cimagl(z);
                // God knows why, but the following is *MUCH* faster than using creall(z)
                long double* zPtr = (long double*)(&z);
                zr = zPtr[0];
                zi = zPtr[1];
                
                // period checking from wiki
                long double xDiff = fabsl(zr - hx);
                if (xDiff < 1e-17l)
                {
                    long double yDiff = fabsl(zi - hy);
                    if (yDiff < 1e-17l)
                    {
                        k = maxIterations;
                        break;
                    }
                }
                // Update history, from the period checking
                if (check == checkCounter)
                {
                    checkCounter = 0;
                    
                    if (update == updateCounter)
                    {
                        updateCounter = 0;
                        check *= 2;
                    }
                    updateCounter++;
                    
                    hx = zr;
                    hy = zi;
                }
                checkCounter++;
                 
                k++;
            }
    
            int pixelNumber = (i * 4) + (int)(j * bitmapBytesPerRow);
            if (k == maxIterations)
            {
                bitmapPtr[pixelNumber + 3] = 255;
                bitmapPtr[pixelNumber + 2] = 0;
                bitmapPtr[pixelNumber + 1] = 0;
                bitmapPtr[pixelNumber + 0] = 0;
            }
            else
            {
                long double vz = k - log2l(log2l(cabsl(z)));
                vz = vz * iterationMagnitude;
                int colorNumber = ((int)vz % numColors);
                bitmapPtr[pixelNumber + 3] = (uint8_t)255;
                bitmapPtr[pixelNumber + 2] = colorTable[colorNumber].blue;
                bitmapPtr[pixelNumber + 1] = colorTable[colorNumber].green;
                bitmapPtr[pixelNumber + 0] = colorTable[colorNumber].red;
            }
        };
        dispatch_apply(bounds.size.height, queue, innerMandelthing);
    };
    
    self.progressTimer = [[NSTimer alloc] initWithFireDate:[NSDate new] interval:0.125f target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSDefaultRunLoopMode]; });
    dispatch_apply(bounds.size.width, queue, mandelthing);
   
    //free(colorTable);
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.progressTimer invalidate]; });
    
    CGContextSetShouldAntialias(context, true);
    CGImageRef image = CGBitmapContextCreateImage(context);
    if ([self isCancelled])
        self.result = nil;
    else
        [self setResult:[UIImage imageWithCGImage:image]];
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self.delegate dismissProgress]; });
    CGImageRelease(image);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(bitmapPtr);
}

- (long double)scaleX:(CGFloat)screenCoord
{
    return ((long double)screenCoord - (long double)(screenCenter.x))/currScaleFactor + (long double)(center.x);
}

- (long double)scaleY:(CGFloat)screenCoord
{
    return (0.0l - ((long double)screenCoord - (long double)(screenCenter.y)))/currScaleFactor + (long double)(center.y);
}

- (void)dealloc
{
    self.colorTable = nil;
}
@end

#ifdef DEBUG
RTPoint RTPointMake(long double x, long double y)
{
    RTPoint point;
    point.x = x;
    point.y = y;
    return point;
}

long double scale_x(CGFloat screenCoord, CGPoint screenCenter, long double currScaleFactor, RTPoint center)
{
    return ((long double)screenCoord - (long double)(screenCenter.x))/currScaleFactor + (long double)(center.x);
}

long double scale_y(CGFloat screenCoord, CGPoint screenCenter, long double currScaleFactor, RTPoint center)
{
    return (0.0l - ((long double)screenCoord - (long double)(screenCenter.y)))/currScaleFactor + (long double)(center.y);
}
#endif
