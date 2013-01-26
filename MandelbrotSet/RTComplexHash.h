//
//  RTComplexHash.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/23/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "complex.h"

@interface RTComplexHash : NSObject
@property (nonatomic) NSUInteger numBuckets;
@property (nonatomic) complex float** table;
@property (nonatomic) BOOL** bucketUsed;
@property (nonatomic) NSUInteger lastHash;
@property (nonatomic) complex float lastZ;
@property (nonatomic) const char* dataFileName;
@property (nonatomic) const char* boolFileName;
@property (nonatomic) FILE* boolFile;
@property (nonatomic) size_t boolFileSize;

- (id)initWithCapacity:(NSUInteger)capacity;
- (void)addComplex:(complex float)number;
- (BOOL)isInTable:(complex float)number;

- (NSUInteger)genHash:(complex float)number;

- (void)clear;
@end
