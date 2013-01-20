//
//  complex.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 11/30/12.
//  Copyright (c) 2012 Robert Stephen Thompson. All rights reserved.
//

#ifndef __MandelbrotSet__complex__
#define __MandelbrotSet__complex__

#include <iostream>
#include <math.h>
class Complex
{
private:
	double real;
	double imaginary;
    int realSgn(double num);
public:
	Complex(double newReal=0.0, double newImaginary=0.0);
    double getRealPart() { return real; } ;
    double getImaginaryPart() { return imaginary; } ;
    
    double abs() { return sqrt(real*real + imaginary*imaginary); };
    Complex sqrtc();
    Complex conjugate();
    Complex reciprocal();
    Complex sgn();
    
    friend Complex operator+(const Complex &op1, const Complex &op2);
    friend Complex operator-(const Complex &op1, const Complex &op2);
    friend Complex operator/(const Complex &op1, const Complex &op2);
    friend Complex operator*(const Complex &op1, const Complex &op2);
};

#endif /* defined(__MandelbrotSet__complex__) */
