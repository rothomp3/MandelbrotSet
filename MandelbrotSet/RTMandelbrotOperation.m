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
void printBits(unsigned int num)
{
    for(int bit=0;bit<(sizeof(unsigned int) * 8); bit++)
    {
        printf("%i ", num & 0x01);
        num = num >> 1;
    }
}

typedef struct
{
    int numIterations;
    long double complex z;
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
    long double iterationMagnitude = log10l(self.maxIterations) * 6.43f;
    
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
            long double q = x2 - (0.5f * x) + 0.0625f + y2;
            long double r = q * (q + (x - 0.25f));

            if ((x2 + x + x + 1.0f + y2 < 0.0625f) || (r < (0.25f * y2))) // inside the period-2 bulb or main carioid
            {
                k = maxIterations;
                z = x + y*I;
            }
            
            // These variables are setup for the period checking
            int check = 3;
            int checkCounter = 0;
            int update = 10;
            int updateCounter = 0;
            long double hx = 0.0f;
            long double hy = 0.0f;
            
            long double zr = 0.0f;
            long double zi = 0.0f;
            while ((k < maxIterations))
            {
                // Check for bailout at radius 2
                if (zr*zr + zi*zi >= 4.0f)
                {
                    break;
                }
                
                // Do the Mandelbrot (/dance)
                z = (z * z) + (x + y*I);

                zr = creall(z);
                zi = cimagl(z);
                
                // period checking from wiki
                long double xDiff = fabsl(zr - hx);
                if (xDiff < 1e-17f)
                {
                    long double yDiff = fabsl(zi - hy);
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
                long double prog = (long double)completed / (long double)totalBitmapSize;
                self.progress.progress = prog;
            });
        };
        dispatch_apply(bounds.size.height, queue, innerMandelthing);
    };
    dispatch_async(dispatch_get_main_queue(), ^(void) { [self.progressLabel setText:@"Calculating escapes…"]; });
    dispatch_apply(bounds.size.width, queue, mandelthing);
    
#if USE_CI
    int width = bounds.size.width;
    int height = bounds.size.height;
    uint32_t* bitmapDataData = malloc(sizeof(uint32_t) * width * height);
    uint32_t** bitmapData = malloc(sizeof(uint32_t*) * width);
    for (int a = 0; a < width; a++)
    {
        bitmapData[a] = bitmapDataData + (a * height);
    }
#endif
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
                long double vz = point.numIterations - log2f(log2f(cabs(point.z)));
                vz = vz * iterationMagnitude;
                int colorNumber = ((int)(truncf(vz)) % (self.colorTable.count));
#if USE_CI
                CGlong double color[4];
                [self.colorTable[colorNumber] getRed:&color[0] green:&color[1] blue:&color[2] alpha:&color[3]];
                for (int m = 0; m < 4; m++)
                {
                    uint8_t* pixelPtr = (uint8_t*)(&(bitmapData[i][j]));
                    pixelPtr[2] = (uint8_t)(ceilf(color[0] * 255.0f));
                    pixelPtr[1] = (uint8_t)(ceilf(color[1] * 255.0f));
                    pixelPtr[0] = (uint8_t)(ceilf(color[2] * 255.0f));
                    pixelPtr[3] = 255;
                }
#else
                CGContextSetFillColorWithColor(context, [self.colorTable[colorNumber] CGColor]);
                //CGContextSetRGBFillColor(context, 0.01f * (long double)i, 0.0f, 0.0f, 1.0f);
#endif
            }
            pixel.origin.x = i;
            pixel.origin.y = j;
            
            completed++;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                long double prog = (long double)completed / (long double)totalBitmapSize;
                self.progress.progress = prog;
            });
#if !USE_CI
            CGContextFillRect(context, pixel);
#endif
        }
    }
#if USE_CI
    NSData* bitmap = [NSData dataWithBytes:bitmapDataData length:(width * height)];
    //CIContext* ctx = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@NO}];
    
    CIImage *theImage = [CIImage imageWithBitmapData:bitmap bytesPerRow:bitmapBytesPerRow size:CGSizeMake(width, height) format:kCIFormatARGB8 colorSpace:colorSpace];
    

    //UIImage *theUIImage = [[UIImage alloc] initWithBitma];
    [self setResult:[UIImage imageWithCIImage:theImage]];
    //[self setResult:theUIImage];
    free(bitmapDataData);
    free(bitmapData);

#else
    CGImageRef image = CGBitmapContextCreateImage(context);
    [self setResult:[UIImage imageWithCGImage:image]];
    CGImageRelease(image);
#endif
    free(data);
    free(bitsMapped);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self.delegate dismissProgress]; });
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
