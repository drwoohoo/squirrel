import controlP5.*;
import java.util.*;
/*
Colors class by Dr. Woohoo!
 
 GUI for Squirrel. Selects an image, LUT style, segments the drawn line,
 and draws a visualization of the swatches.
 */

public class ControlFrame extends PApplet {
  int w, h;
  int cfX = 20;
  int ySpacer = 5;
  int sliderH = 15;
  PApplet parent;
  ControlP5 cp5;

  int SWATCH_HEIGHT = 100;
  PFont font;
  List l;
  List lutN;


  public ControlFrame(PApplet _parent, int _w, int _h, String _name, String[] _lutNames) {
    super();
    parent = _parent;
    w=_w;
    h=_h;
    l = Arrays.asList(imageNames);
    lutN = Arrays.asList(_lutNames);
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h, P2D);
  }

  public void setup() {
    font = createFont("arial", 12);
    cp5 = new ControlP5(this);


    cp5.addBang("select_image")
      .setPosition(cfX, 20+ySpacer)
      .setSize(80, sliderH)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      ;

    cp5.addSlider("Saturation")
      .setPosition(cfX, 40+ySpacer)
      .setRange(0.0, 2.0)
      .setSize(160, sliderH)
      .setFont(font)
      .setValue(satIntensity)
      .plugTo(parent, "satIntensity")
      ;

    cp5.addSlider("Brightness")
      .setPosition(cfX, 60+ySpacer)
      .setRange(-255, 255)
      .setSize(160, sliderH)
      .setFont(font)
      .setValue(briIntensity)
      .plugTo(parent, "briIntensity")
      ;

    cp5.addSlider("Contrast")
      .setPosition(cfX, 80+ySpacer)
      .setRange(-1.0, 1.0)
      .setSize(160, sliderH)
      .setFont(font)
      .setValue(contIntensity)
      .plugTo(parent, "contIntensity")
      ;

    cp5.addSlider("Glitch")
      .setPosition(cfX, 100+ySpacer)
      .setRange(0, 4)
      .setSize(160, sliderH)
      .setFont(font)
      .setValue(glitchIntensity)
      .plugTo(parent, "glitchIntensity")
      ;

    cp5.addSlider("Bloom")
      .setPosition(cfX, 120+ySpacer)
      .setRange(0, 255)
      .setSize(160, sliderH)
      .setFont(font)
      .setValue(bloomIntensity)
      .plugTo(parent, "bloomIntensity")
      ;

    cp5.addSlider("Lights")
      .setPosition(cfX, 140+ySpacer)
      .setRange(-1.0, 1.0)
      .setSize(160, sliderH)
      .setFont(font)
      .setValue(lightsIntensity)
      .plugTo(parent, "lightsIntensity")
      ;

    cp5.addSlider("Palette Size")
      .setPosition(cfX, 160+ySpacer)
      .setRange(2, 100)
      .setValue(palSize)
      .setSize(160, sliderH)
      .setFont(font)
      .plugTo(parent, "palSize")
      ;

    cp5.addBang("export")
      .setPosition(cfX, 200+ySpacer)
      .setSize(80, sliderH)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      ;

    cp5.addScrollableList("select_lut_style")
      .setPosition(cfX, 180+ySpacer)
      .setSize(200, 140)
      .setBarHeight(sliderH)
      .setItemHeight(sliderH)
      .addItems(lutN)
      .close()
      ;
  }

  void draw() {
    background(20);
    surface.setLocation(10, 100);
    swatches();
  }

  void select_image(int n) {
    selectInput("Select a file to process:", "loadSelectedFile");
  }

  public void loadSelectedFile(File selection) {
    println("fileSelected called");
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      loadAnyImg(selection.getAbsolutePath());
    }
  }

  void select_lut_style(int n) {
    currentLutIndex = n;
  }

  // Called by Main > init()
  void segmentedLineBySteps() {
    PVector a = targetPts.get(0);
    PVector b = targetPts.get(1);
    float distX = (b.x - a.x)/palSize;
    float distY = (b.y - a.y)/palSize;

    for (int i = 0; i < palSize+1; i++) {
      float newX = a.x + (distX * i);
      float newY = a.y + (distY * i);
      squirrel.move(i, new PVector(newX, newY));
    }

    colors.cullPalette();
  }

  void drawSwatch(color c, float x_, int sid, float w_) {
    strokeWeight(1);
    color cc = color(red(c), green(c), blue(c));
    fill(cc);
    rect(x_, height-SWATCH_HEIGHT, w_, SWATCH_HEIGHT);
  }

  void swatches() {
    try {
      IntList cs = colors.getCulledPalette();
      float newW = float(width)/float(cs.size());
      if (newW <= 0.5) newW = 1.0;
      for (int i = 0; i < cs.size(); i++) {
        color c = cs.get(i);
        drawSwatch(c, newW*i, i, newW);
      }
    }
    catch (Exception e) {
      // A palette has yet to be created
      println("Uh-oh! : "+e);
    }
  }

  public void export() {
    selectOutput("Save the palette", "fileSelected");
  }

  void fileSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      println("Saved as " + selection.getAbsolutePath());

      String fn = selection.getAbsolutePath();
      
      colors.exportColors(fn);
    }
  }
}
