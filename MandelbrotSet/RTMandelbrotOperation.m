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
@synthesize bounds, currScaleFactor, center, screenCenter;
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
- (void)main
{
    size_t bitmapBytesPerRow = bounds.size.width * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    
    screenCenter.x = bounds.size.width / 2.0f;
    screenCenter.y = bounds.size.height / 2.0f;
    
    long double iterationMagnitude = log10l(self.maxIterations) * 6.43f;
    
    size_t totalBitmapSize = bounds.size.width * bounds.size.height;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    uint8_t* bitmapPtr = malloc(sizeof(uint8_t) * totalBitmapSize * 4);
    CGContextRef context = CGBitmapContextCreate(bitmapPtr, bounds.size.width, bounds.size.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    
    __block int completed = 0;
    int maxIterations = self.maxIterations;
    
    void (^updateProgress)(void) =  ^(void){
        float prog = (float)completed / (float)totalBitmapSize;
        self.progress.progress = prog;
    };
    
    // set up the color table for fast access
    NSRange colorRange = NSMakeRange(0, self.colorTable.count);
    UIColor* __unsafe_unretained * colorTable = (UIColor * __unsafe_unretained *)malloc(sizeof(id *) * colorRange.length);
    [self.colorTable getObjects:colorTable range:colorRange];
    int numColors = self.colorTable.count;
    
    void (^mandelthing)(size_t i) = ^(size_t i)
    {
        void (^innerMandelthing)(size_t j) = ^(size_t j)
        {
            // first we get the correctly scaled (x,y) point c
            long double x = [self scaleX:i];
            long double y = [self scaleY:j];
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
                if (xDiff < 1e-18l)
                {
                    long double yDiff = fabsl(zi - hy);
                    if (yDiff < 1e-18l)
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
                UIColor* color = colorTable[colorNumber];
                CGFloat red, green, blue, alpha;
                [color getRed:&red green:&green blue:&blue alpha:&alpha];
                bitmapPtr[pixelNumber + 3] = (uint8_t)255; //(uint8_t)ceilf(alpha * 255.0f);
                bitmapPtr[pixelNumber + 2] = (uint8_t)ceilf(blue * 255.0f);
                bitmapPtr[pixelNumber + 1] = (uint8_t)ceilf(green * 255.0f);
                bitmapPtr[pixelNumber + 0] = (uint8_t)ceilf(red * 255.0f);
            }
            completed++;
            if (completed % 5000 == 0) // only when completed is divisible by twenty
            {
                dispatch_async(dispatch_get_main_queue(), updateProgress);
            }
        };
        dispatch_apply(bounds.size.height, queue, innerMandelthing);
    };
    
    dispatch_async(dispatch_get_main_queue(), ^(void) { [self.progressLabel setText:@"Calculating and drawing…"]; [self.progressLabel sizeToFit];
        self.progressLabel.center = CGPointMake(self.progress.center.x, 0.0f - self.progressLabel.bounds.size.height - 5.0f + self.progress.center.y);});
    dispatch_apply(bounds.size.width, queue, mandelthing);
   
    CGImageRef image = CGBitmapContextCreateImage(context);
    [self setResult:[UIImage imageWithCGImage:image]];
    CGImageRelease(image);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self.delegate dismissProgress]; });
    free(bitmapPtr);
    free(colorTable);
}

- (long double)scaleX:(CGFloat)screenCoord
{
    return ((long double)screenCoord - (long double)(screenCenter.x))/currScaleFactor + (long double)(center.x);
}

- (long double)scaleY:(CGFloat)screenCoord
{
    return (0.0f - ((long double)screenCoord - (long double)(screenCenter.y)))/currScaleFactor + (long double)(center.y);
}
@end

RTPoint RTPointMake(long double x, long double y)
{
    RTPoint point;
    point.x = x;
    point.y = y;
    return point;
}
