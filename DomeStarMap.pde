class DomeStarMap {
  class MapEntry {
    int x;    // x position on dome image
    int y;    // y position on dome image
    float d;  // distance to pixel (0.0-1.0)
  }
  
  MapEntry[] lookup;
  color[] buffer;
  
  public DomeStarMap() {
    lookup = new MapEntry[360*360];
    buffer = new color[160*40];
    this.buildMap();
  }
  
  // Builds the lookup table by calculating distance to 
  // the strip to the left of each point.  We step through
  // the circle 1/3200th the circumference at a time.  It's
  // wasteful, but it only has to be done once.
  //
  // Leaves a 20 pixel buffer at the center of the circle
  // to represent the offset of the boxes from the true
  // center of the dome.
  public void buildMap() {   
    for (int i=0; i<lookup.length; i++) {
      lookup[i] = new MapEntry();
    }

    for (int i=0; i<3200; i++) {
      float radians = TWO_PI/3200*i;
      int strip = i/80;
      float distance = (1-(i%80/80.0));

      for (int j=20; j<180; j++) {
        int x = int(180+sin(radians)*j);
        int y = int(180+cos(radians)*j);
        int led = j-20;
        int idx = (y*360+x);
        
        lookup[idx].x = strip;
        lookup[idx].y = led;
        lookup[idx].d = distance;
      }
    }
  }
  
  // Apply the map by walking the 360x360 image and lerping
  // the color of the strip to the left and lerp the inverse
  // of the strip on the right.
  public color[] applyMap() {
    PImage image = get(0,0,360,360);
    image.loadPixels();
    MapEntry m;
    int idx,x;
    color c;
    
    for (int i=0; i<image.pixels.length; i++) {
      m = lookup[i];
      x = m.x;
      c = image.pixels[i];
      
      idx = m.y*40+x;
      buffer[idx] = lerpColor(buffer[idx],c,m.d);
      
      x++;
      if (x>39) x = 0;
      idx = m.y*40+x;
      
      buffer[idx] = lerpColor(buffer[idx],c,1.0-m.d);
    }
    
    return buffer;
  }
}