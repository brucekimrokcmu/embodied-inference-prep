// Add two overloaded constructors to a Point class using Google-style class layout: 
// a default constructor and one that accepts x and y. 
// Keep data private and expose int x() const and int y() const accessors.

class Point {
public:
    Point() = default;
    Point(int x, int y) 
    : x_(x),
      y_(y)
    {
    }

    int x() const { return x_; }
    int y() const { return y_; }

private:
    int x_ = 0;
    int y_ = 0;

};