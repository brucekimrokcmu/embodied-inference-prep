// Practice basic inheritance without polymorphism: define an empty Shape base
// class, then publicly derive Circle. Give Circle an explicit constructor that
// accepts a double radius, a double radius() const accessor, and a private
// radius_ member. Polymorphic destruction is covered in Q16.

#include <iostream>

class Shape {};

class Circle : public Shape {
public:
    explicit Circle (double radius) 
    : radius_(radius)
    {
        
    }

    double radius() const { return radius_; }

private:
    double radius_;
};