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

#define USE_CI 0

typedef struct
{
    int numIterations;
    float complex z;
} pointInfo;

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
    CGContextRef context = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    
    screenCenter.x = bounds.size.width / 2.0f;
    screenCenter.y = bounds.size.height / 2.0f;
    
    CGRect pixel = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    float iterationMagnitude = log10l(self.maxIterations) * 6.43f;
    
    size_t totalBitmapSize = bounds.size.width * bounds.size.height;
    pointInfo* data = malloc(sizeof(pointInfo) * totalBitmapSize);
    pointInfo** bitsMapped = malloc(sizeof(pointInfo*) * bounds.size.width);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(bounds.size.width, queue, ^(size_t j) { bitsMapped[j] = data + (j * (int)bounds.size.height); });
    
    __block int completed = 0;
    int maxIterations = self.maxIterations;
    void (^mandelthing)(size_t i) = ^(size_t i)
    {
        void (^innerMandelthing)(size_t j) = ^(size_t j)
        {
            float x = [self scaleX:i];
            float y = [self scaleY:j];/*
            RTMandelbrot* parallelbrot = [[RTMandelbrot alloc] initWithPoint:(x + y*I) andMaxIterations:self.mandelbrot.maxIterations];
            [parallelbrot doPoint];
            bitsMapped[i][j].numIterations = [parallelbrot escapedAt];
            bitsMapped[i][j].z = [parallelbrot zn];
                                       */
            int k = 1;
            complex float z = 0.0f;
            
            float y2 = y * y;
            float x2 = x * x;
            // next two lines are for checking the main cardioid
            float q = x2 - (0.5f * x) + 0.0625f + y2;
            float r = q * (q + (x - 0.25f));
            
            float zr = 0.0f;
            float zi = 0.0f;
            if ((x2 + x + x + 1.0f + y2 < 0.0625f) || (r < (0.25f * y2))) // inside the period-2 bulb or main carioid
            {
                k = maxIterations;
                z = x + y*I;
            }
            
            int check = 3;
            int checkCounter = 0;
            int update = 10;
            int updateCounter = 0;
            float hx = 0.0f;
            float hy = 0.0f;
            
            while ((k < maxIterations))
            {
                float zrr = zr*zr;
                float zii = zi*zi;
                
                if (zrr + zii >= 4.0f)
                {
                    break;
                }
                z = (z * z) + (x + y*I);
                //z = (2.8 * zr * zi + y) + (zrr - zii + x)*I;
                //zr = 2.0f * zr * zi + y;
                //zi = zrr - zii + x;
                zr = crealf(z);
                zi = cimagf(z);
                // period checking from wiki
                float xDiff = fabsf(zr - hx);
                if (xDiff < 1e-17f)
                {
                    float yDiff = fabsf(zi - hy);
                    if (yDiff < 1e-17f)
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
            if (k == maxIterations) //it didn't escape
            {
                bitsMapped[i][j].numIterations = -1;
            }
            else
            {
                bitsMapped[i][j].numIterations = k;
            }
            bitsMapped[i][j].z = z;
            completed++;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                float prog = (float)completed / (float)totalBitmapSize;
                self.progress.progress = prog;
            });
        };
        dispatch_apply(bounds.size.height, queue, innerMandelthing);
    };
    dispatch_async(dispatch_get_main_queue(), ^(void) { [self.progressLabel setText:@"Calculating escapes…"]; });
    dispatch_apply(bounds.size.width, queue, mandelthing);
    int width = bounds.size.width;
    int height = bounds.size.height;
    
    int32_t* bitmapDataData = malloc(sizeof(int32_t) * width * height);
    int32_t** bitmapData = malloc(sizeof(int32_t*) * width);
    for (int a = 0; a < width; a++)
    {
        bitmapData[a] = bitmapDataData + (a * height);
    }
    
    pointInfo point;
    completed = 0;
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self.progressLabel setText:@"Drawing bitmap…"]; });
    for (int i = 0; i < bounds.size.width; i++)
    {
        for (int j = 0; j < bounds.size.height; j++)
        {
            point = bitsMapped[i][j];
            if (point.numIterations == -1)
            {
                CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
            }
            else
            {
                float vz = point.numIterations - log2l(log2l(cabs(point.z)));
                vz = vz * iterationMagnitude;
                int colorNumber = ((int)(truncl(vz)) % (self.colorTable.count));
#if USE_CI
                CGFloat color[4];
                [self.colorTable[colorNumber] getRed:&color[0] green:&color[1] blue:&color[2] alpha:&color[3]];
                for (int m = 0; m < 4; m++)
                {
                    int8_t* pixelPtr = (int8_t*)(&(bitmapData[i][j]));
                    pixelPtr[0] = (int)color[0] % 255;
                    pixelPtr[1] = (int)color[1] % 255;
                    pixelPtr[2] = (int)color[2] % 255;
                    pixelPtr[3] = (int)color[3] % 255;
                }
#else
                CGContextSetFillColorWithColor(context, [self.colorTable[colorNumber] CGColor]);
#endif
            }
            pixel.origin.x = i;
            pixel.origin.y = j;
            
            completed++;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                float prog = (float)completed / (float)totalBitmapSize;
                self.progress.progress = prog;
            });
#if !USE_CI
            CGContextFillRect(context, pixel);
#endif
        }
    }
#if USE_CI
    NSData* bitmap = [NSData dataWithBytesNoCopy:bitmapDataData length:(width * height)];
    CIImage *theImage = [CIImage imageWithBitmapData:bitmap bytesPerRow:bitmapBytesPerRow size:CGSizeMake(width, height) format:kCIFormatRGBA8 colorSpace:colorSpace];
    [self setResult:[UIImage imageWithCIImage:theImage]];
    free(data);
    free(bitsMapped);
#else
    CGImageRef image = CGBitmapContextCreateImage(context);
    [self setResult:[UIImage imageWithCGImage:image]];
    CGImageRelease(image);
#endif
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self.delegate dismissProgress]; });
}

- (float)scaleX:(CGFloat)screenCoord
{
    return ((float)screenCoord - (float)(screenCenter.x))/currScaleFactor + (float)(center.x);
}

- (float)scaleY:(CGFloat)screenCoord
{
    return (0.0f - ((float)screenCoord - (float)(screenCenter.y)))/currScaleFactor + (float)(center.y);
}
@end
