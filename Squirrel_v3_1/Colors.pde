/*
Colors class by Dr. Woohoo!

Gets colors from a specific location, stores, and exports the colors as a TXT file.
*/


class Colors {
  IntList palette;
  IntList culledPalette;
  PrintWriter output;

  // Constructor
  Colors() {    
    resetPalette();
  }


  color getColor(PVector position) {
    int pos = int(position.x) + int(position.y)*adjustedImg.width;
    color c = adjustedImg.pixels[pos];
    storeColor(c);
    return c;
  }

  void storeColor(color c_) {
    palette.append(c_);
  }

  // Converts color IntList to a string and saves the text file
  void exportColors(String fn) {
    // Cull palette
    cullPalette();

    // Format of the string: int[] palette = {color(255, 0, 0), color(0, 255, 0), color(0, 0, 255)};    
    String paletteStr = "int[] palette = {"; 
    for (int i = 0; i < culledPalette.size(); i++) {
      paletteStr += "color(" + red(culledPalette.get(i))+", "+green(culledPalette.get(i))+", "+blue(culledPalette.get(i))+")";
      if (i < culledPalette.size()-1)paletteStr += ", ";
    }
    paletteStr += "};";
    
    output = createWriter(fn + ".txt");
    output.println(paletteStr);
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file

    println("exported "+ culledPalette.size() + " colors out of "+palette.size()+"\n"+paletteStr);
  }

  void cullPalette() {
    IntList cPal = new IntList();
    int stepSize = palette.size() / palSize;

    if (debug) {
      println("\ncullPalette \nstepSize = "+stepSize);
      println("palette.size() / palSize: "+palette.size()+" / "+palSize);
    }

    if (stepSize <= 0) stepSize = 1; 
    for (int i = 0; i < palSize; i++) {
      cPal.append(palette.get(i*stepSize));
    }    
    culledPalette = cPal;    

    if (debug) {
      println("culledPalette.size(): "+culledPalette.size());
    }
  }

  void resetPalette() {
    palette = new IntList();
    culledPalette = new IntList();
  }

  IntList getCulledPalette() {
    return culledPalette;
  }

  int getSize() {
    return culledPalette.size();
  }

  void convertColors() {
  }
}
