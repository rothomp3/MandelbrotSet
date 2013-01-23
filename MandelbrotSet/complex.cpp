//
//  complex.mm
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 11/30/12.
//  Copyright (c) 2012 Robert Stephen Thompson. All rights reserved.
//

#include "complex.h"



Complex Complex::sqrt()
{
    double realPart = std::sqrt((real + this->abs()) / 2.0);
    double imgPart = (double)realSgn(imaginary) * (std::sqrt(((-real) + this->abs()) / 2.0));
    return Complex(realPart, imgPart);
}

Complex Complex::conjugate()
{
    return Complex(real, -imaginary);
}

Complex Complex::reciprocal()
{
    return (this->conjugate()) / this->abs2();
}

Complex Complex::sgn()
{
    if (real == 0 && imaginary == 0)
        return Complex(0.0, 0.0);
    return (*this)/this->abs();
}

int Complex::realSgn(const double& num) const
{
    if (num == 0)
        return 0;
    if (num < 0)
        return -1;
    else
        return 1;
}



Complex operator-(const Complex &op1, const Complex &op2)
{
    return Complex(op1.real - op2.real, op1.imaginary - op2.imaginary);
}



Complex operator/(const Complex &op1, const Complex &op2)
{
    double a, b, c, d;
    a = op1.real;
    b = op1.imaginary;
    c = op2.real;
    d = op2.imaginary;
    
    return Complex((a*c + b*d)/(c*c + d*d), (b*c - a*d)/(c*c+d*d));
}

