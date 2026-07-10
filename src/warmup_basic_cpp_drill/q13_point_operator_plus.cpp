// Overload operator+ for a small Point class with private x_ and y_ members
// plus int x() const and int y() const accessors.

class Point {
public:
    Point() = default;
    Point(int x, int y)
    : x_(x), y_(y)
    {
    }

    int x() const { return x_; }
    int y() const { return y_; }

private:
    int x_ = 0;
    int y_ = 0;

};

Point operator+(Point lhs, Point rhs) {
        return Point(lhs.x()+rhs.x(), lhs.y()+rhs.y());
}