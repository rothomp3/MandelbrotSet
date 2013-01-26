//
//  RTComplexHash.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/23/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTComplexHash.h"
#include <sys/types.h>
#include <sys/mman.h>
#include <stdio.h>
#include <errno.h>
#define USE_MURMUR 1

#if USE_MURMUR
void MurmurHash3_x86_32  ( const void * key, int len, uint32_t seed, void * out );
#endif

static const NSUInteger ALLOWED_OOPS = 11;
@implementation RTComplexHash
@synthesize table, numBuckets, bucketUsed;
- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self)
    {
        NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *file = [cachesFolder stringByAppendingPathComponent:@"tableData.dat"];
        [self setDataFileName:[file cStringUsingEncoding:NSUTF8StringEncoding]];
        FILE* dataFP = fopen([self dataFileName], "wb+");
        file = nil;
        file = [cachesFolder stringByAppendingPathComponent:@"bucketData.dat"];
        [self setBoolFileName:[file cStringUsingEncoding:NSUTF8StringEncoding]];
        [self setBoolFile:fopen([self boolFileName], "wb+")];
        size_t length = sizeof(complex float) * capacity * ALLOWED_OOPS +1;
        size_t boolLength = sizeof(BOOL) * capacity * ALLOWED_OOPS + 1;
        [self setBoolFileSize:boolLength];
        int fd = fileno(dataFP);
        fseek(dataFP, length, SEEK_SET);
        fprintf(dataFP, "%c", '\0');
        fseek([self boolFile], boolLength, SEEK_SET);
        fprintf([self boolFile], "%c", '\0');
        off_t offset = 0;
        complex float* data = mmap(NULL, length, PROT_WRITE | PROT_READ | PROT_EXEC, MAP_FILE | MAP_SHARED, fd, offset);
        fclose(dataFP);
        NSLog(@"the value of data is %lu", (unsigned long)data);
        if (data == MAP_FAILED)
        {
            NSLog(@"Ah, you see, map failed… with errno %d", errno);
        }
        fd = fileno([self boolFile]);
        BOOL* boolData = mmap(NULL, boolLength, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_FILE | MAP_SHARED, fd, offset);
        fclose([self boolFile]);
        table = malloc(sizeof(complex float*) * capacity);
        
        bucketUsed = malloc(sizeof(BOOL*) * capacity);
        for (int i = 0; i < capacity; i++)
        {
            table[i] = data + (i * ALLOWED_OOPS);
            bucketUsed[i] = boolData + (i * ALLOWED_OOPS);
        }
        [self setNumBuckets:capacity];
    }
    return self;
}

- (id)init
{
    return [self initWithCapacity:0];
}

- (void)addComplex:(_Complex float)number
{
    NSUInteger hash = [self genHash:number];
    for (int i = 0; i < ALLOWED_OOPS; i++)
    {
        if (bucketUsed[hash][i] == NO) // the value is not in the table
        {
            bucketUsed[hash][i] = YES;
            table[hash][i] = number;
            return;
        }
        if (i == (ALLOWED_OOPS - 1))
        {
            NSLog(@"Whoops too many collisions");
            exit(EXIT_FAILURE);
        }
    }
    return;
}

- (BOOL)isInTable:(_Complex float)number
{
    NSUInteger hash = [self genHash:number];
    for (int i = 0; i < ALLOWED_OOPS; i++)
    {
        if (bucketUsed[hash][i] == YES)
        {
            if (table[hash][i] == number)
                return YES;
            else
                continue;
        }
        else
            return NO;
    }
    
    return NO;
}

- (NSUInteger)genHash:(_Complex float)number
{
    if (number == [self lastZ])
        return [self lastHash];
    
    NSUInteger hash;
    MurmurHash3_x86_32(&number, sizeof(number), numBuckets, &hash);

    [self setLastHash:hash % numBuckets];
    [self setLastZ:number];
    return _lastHash;
}

- (void)clear
{
    memset(bucketUsed[0], 0, (numBuckets * ALLOWED_OOPS * sizeof(BOOL)));
}

- (void)dealloc
{
    munmap(table[0], sizeof(complex float) * numBuckets * ALLOWED_OOPS);
    //fclose([self dataFile]);
    munmap(bucketUsed[0], [self boolFileSize]);
    free(table);
    free(bucketUsed);
}
@end
