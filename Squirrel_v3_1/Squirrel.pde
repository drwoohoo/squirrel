/*
Squirrel class by Dr. Woohoo!

The Squirrel utilizes the different positions along a line, moving from
one to the next and squirreling away the colors at each location as it 
proceeds from one point to the next.
*/

class Squirrel {
  PVector position;

  Squirrel() {
    position = new PVector(x, y);
  }

  void move(int i, PVector _position) {
    position = _position;    
    color c = colors.getColor(position);
    fill(c);    
    stroke(0);
    ellipse(position.x, position.y, 10, 10);
  }

  void display() {
  }
}
