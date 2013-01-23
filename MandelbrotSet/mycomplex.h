//
//  mycomplex.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 11/30/12.
//  Copyright (c) 2012 Robert Stephen Thompson. All rights reserved.
//

#ifndef __MandelbrotSet__complex__
#define __MandelbrotSet__complex__

#include <functional>
#include <cmath>

class Complex
{
private:
	double real;
	double imaginary;
    int realSgn(const double& num) const;

public:
	inline Complex(double newReal=0.0, double newImaginary=0.0) :
    real(newReal), imaginary(newImaginary) {};
    inline double getRealPart() const { return real; } ;
    inline double getImaginaryPart() const { return imaginary; } ;
    
    inline const double const abs()
    {
        return std::sqrt(this->abs2());
    };
    inline const double const abs2()
    {
        return (real * real) + (imaginary * imaginary);
    };
    Complex sqrt();
    Complex conjugate();
    Complex reciprocal();
    Complex sgn();
    
    Complex& operator*=(const Complex& other);
    Complex& operator+=(const Complex& other);
    
    friend bool operator==(const Complex& lhs, const Complex& rhs);
    friend bool operator!=(const Complex& lhs, const Complex& rhs);
    friend bool operator<(const Complex& lhs, const Complex& rhs);
    friend bool operator>(const Complex& lhs, const Complex& rhs);
    friend bool operator<=(const Complex& lhs, const Complex& rhs);
    friend bool operator>=(const Complex& lhs, const Complex& rhs);
    friend Complex operator+(const Complex &op1, const Complex &op2);
    friend Complex operator-(const Complex &op1, const Complex &op2);
    friend Complex operator/(const Complex &op1, const Complex &op2);
    friend Complex operator*(const Complex &op1, const Complex &op2);
};

namespace std
{
    template<> struct hash<Complex>
    {
    public:
        inline size_t operator()(const Complex& val) const
        {
            size_t h1 = std::hash<double>()(val.getRealPart());
            size_t h2 = std::hash<double>()(val.getImaginaryPart());
            
            return h1 ^ (h2 << 1);
        }
    };
};

inline bool operator==(const Complex& lhs, const Complex& rhs)
{
    return ((lhs.real == rhs.real) && (lhs.imaginary == rhs.imaginary));
}

inline bool operator!=(const Complex& lhs, const Complex& rhs)
{
    return !operator==(lhs, rhs);
}

inline bool operator<(const Complex& lhs, const Complex& rhs)
{
    return std::hash<Complex>()(lhs) < std::hash<Complex>()(rhs);
}

inline bool operator>(const Complex& lhs, const Complex& rhs)
{
    return operator<(rhs, lhs);
}

inline bool operator<=(const Complex& lhs, const Complex& rhs)
{
    return !operator>(lhs,rhs);
}

inline bool operator>=(const Complex& lhs, const Complex& rhs)
{
    return !operator<(lhs, rhs);
}

inline Complex operator+(const Complex &op1, const Complex &op2)
{
    double newReal = op1.real + op2.real;
    double newImaginary = op1.imaginary + op2.imaginary;
    
    return Complex(newReal, newImaginary);
}

inline Complex& Complex::operator+=(const Complex& other)
{
    double newReal = real + other.real;
    double newImaginary = imaginary + other.imaginary;
    
    real = newReal;
    imaginary = newImaginary;

    return *this;
}

inline Complex operator*(const Complex &op1, const Complex &op2)
{
    return Complex((op1.real * op2.real) - (op1.imaginary * op2.imaginary), (op1.imaginary * op2.real) + (op1.real * op2.imaginary));
}

inline Complex& Complex::operator*=(const Complex& other)
{
    double newReal = (real * other.real) - (imaginary * other.imaginary);
    double newImaginary = (imaginary * other.real) + (real * other.imaginary);
    real = newReal;
    imaginary = newImaginary;
    return *this;
}

#endif /* defined(__MandelbrotSet__complex__) */
