/*
The objective of this app is to sample colors from an imported image and then to save each one
 as a color palette int array to be used later in a different Processing sketch.
 
 * Note: This sketch requires the "Image Processing Algorithms" developed Nick 'Milchreis' Müller &
 the ControlP5 libraries. To download:
 1) In the Processing menus, select Tools > Add Tool...
 2) Click on the Libraries tab in the top-left corner
 3) In the textfield with a magnifying glass and the word "Filter", type "Image processing algorithms"
 4) Select it in the list that shows up below
 5) Click on the "Install" button in the lower right section of the window.
 6) Repeat steps 1-5, replacing "Image processing algorithms" with "ControlP5"
 
 Simple start:
 1) A default image automatically loads from the data/images folder.
 2) Click on the main "Squirrel_v[version #]" window
 3) Click twice any where! The 1st click defines the starting point, the 2nd click, the end point. Colors will
 be sampled in-between. Note that in the ControlFrame window, the colors are displayed. Rinse-and-repeat until
 you have selected a color palette you like.
 4) To save the palette, click on the "EXPORT" button. A save dialog will appear. 
 
 Import an image:
 1) Click the "SELECT_IMAGE" button from the ControlFrame window
 2) Select an image (png,jpg,jpeg,gif,tif,tiff,tga,bmp,wbmp)from your hard drive. 
 The image will load in the main window.
 
 Change the size of the colors captured:
 In the ControlFrame window:
 1) Click and/or drag in the scroll area to the left of the label "PALETTE SIZE"
 
 Adjust the brightness, contrast, and glitch:
 In the ControlFrame window:
 1) Click and/or drag in the scroll area to the left of the label "BRIGHTNESS", "CONTRAST", or "GLITCH"
 

 *New!
 1) LUT image processing effects and arrays integrated into a dropdown GUI
 2) Bloom effect & GUI
 3) Lights effect& GUI
 4) On startup, load a random image from the imageNames array
 
 **Improved!
 1) GUI layout
 2) Selecting files to analyze and where to save the exported color palette info.
 3) Using a save dialog to export the palettes as a text file. 
 
 Developed by Dr. Woohoo!
 https://linktr.ee/drwoohoo
 */

import milchreis.imageprocessing.*;

// CLASSES
Squirrel squirrel;
Colors colors;

// LOAD FILES
static final String PICS_EXTS = "extensions=,png,jpg,jpeg,gif,tif,tiff,tga,bmp,wbmp";
File dir;
File[] files = {};
String[] imagePaths = {};
String[] imageNames;
PImage origImg, adjustedImg;
int imgIndex;

// COLOR
PVector position;
float x, y;
ArrayList<PVector> targetPts;
ArrayList<PVector> colorSamplePts;
AdjustPixels ap;

// TARGET PALETTE
Table colorTable;
int id;
String type, brand, name, hex, r, g, b, instock;
int[] targetPalette;

// GUI
ControlFrame cf;
int palSize;
float adjustSaturation;
int steps;
int currentLutIndex = 0;

float satIntensity, contIntensity, lightsIntensity, highlightsIntensity, shadowsIntensity;
int briIntensity, glitchIntensity, bloomIntensity;

LUT[] lookuptables;
String[] lutNames;

boolean debug = true;

void settings() {
  size(800, 600, P3D);
}

void setup() {
  frameRate(60);

  imgIndex = 0;

  // LOAD IMAGES IN DATA FOLDER
  listDataFiles();

  lookuptables = new LUT[LUT.STYLE.values().length];
  lutNames = new String[lookuptables.length];
  listLutNames();

  position = new PVector(0, 0);
  squirrel = new Squirrel();

  // GUI
  palSize = 70;
  adjustSaturation = 1.0;
  targetPts = new ArrayList<PVector>();

  // Load a random image from the array
  loadImg(int(random(0, imageNames.length-1)));
  cf = new ControlFrame(this, 300, 340, "box", lutNames);
  ap = new AdjustPixels();

  colors = new Colors();
}

void draw() {
  ap.update();

  try {
    drawTargets();
  }
  catch (Exception e) {
    println("error: "+e);
  }
}

// Called by defineTargets()
void init(float x_, float y_) {
  // Define the initial x & y locations for the squirrel
  x = x_;
  y = y_;

  colors = new Colors();
  cf.segmentedLineBySteps();
}

// List the image files located in the data/images folder
void listDataFiles() {
  dir = dataFile("");

  if (dir.isDirectory()) {
    files = listFiles(dir.getPath()+"/images");
    imagePaths = listPaths(dir.getPath(), "files", "recursive", PICS_EXTS);
  }
  imageNames = new String[imagePaths.length];

  for (int i = 0; i < imagePaths.length; i++) {
    File img = files[i];
    imageNames[i] = img.getName();
  }
}

void loadImg(int f) {
  origImg = loadImage(imagePaths[f]);
  resizeImg();
  adjustedImg = createImage(origImg.width, origImg.height, RGB);
}

void loadAnyImg(String imgPath) {
  origImg = loadImage(imgPath);
  resizeImg();
  adjustedImg = createImage(origImg.width, origImg.height, RGB);
}

// Resize to fill screen NOTE: resize to stay proportion wasn't happy w/pixel arrays. Bug?
void resizeImg() {
  origImg.resize(width, height);
  image(origImg, 0, 0);
}

void listLutNames() {
  // Create an array with all lookup-tables
  // LUT Styles: RETRO, CONTRAST, CONTRAST_STRONG, ANALOG1, WINTER, SPRING, SUMMER, AUTUMN
  for (int i=0; i<lookuptables.length; i++) {
    lookuptables[i] = LUT.loadLut(LUT.STYLE.values()[i]);
    String stylename = LUT.STYLE.values()[i].name();
    lutNames[i] = stylename;
  }
}

// Called by mousePressed()
// Add Points A & B to an array. Points A & B are the beginning and ending of the path that will be sampled for colors
void defineTargets() {
  if (targetPts.size() == 0) {
    // add the 1st point
    targetPts.add(new PVector(mouseX, mouseY));
  } else if (targetPts.size() == 1) {
    // add the 2nd point & move forward
    targetPts.add(new PVector(mouseX, mouseY));
    init(targetPts.get(0).x, targetPts.get(0).y);
  } else if (targetPts.size() == 2) {
    // Remove previous pts and start again
    targetPts = new ArrayList<PVector>();
    // add the 1st point
    targetPts.add(new PVector(mouseX, mouseY));
  }
}

// Draw Points A & B
void drawTargets() {
  strokeWeight(2);
  stroke(0);
  for (int i = 0; i < targetPts.size(); i++) {
    ellipse(targetPts.get(i).x, targetPts.get(i).y, 10, 10);
  }
}

void mouseReleased() {
  defineTargets();
}

void keyPressed() {
  if (key == 'd') {
    debug = !debug;
  }
}

/*
CHANGELOG
 v3_1
 - Fixed a bug with ControlP5 in order for the ControlFrame to work in Processing v4.x.x
 - Select Input launches a dialog window to select an image instead of using a menu
 - Export launches a selectOutput dialog with all of the typical options of a save dialog.
 - Readjusted the positions of the GUI items 
 - Confirmed the export filename textfield is not empty. Alert if it is.
 - Decreased the height of the ControlFrame window
 - Default Palette Size = 70
 - Deleted createColorTable() method. It's not necessary for this app.
 - Removed several keyPress conditions
 
 v3_0
 - Updated the RGB values in the spreadsheet to match the actaul marker colors *after* they drew on the substrate
 - New code to import the target colors from CSV file
 - Added additional folders (images, csv) in data to clean it up
 
 - The target color palette is now generated in NodeBox using a color combinatorics algorithm
 
 v2_4
 - Added Lights effect and GUI
 - Fixed a bug with the select_image dropdown code
 
 v2_3
 - Added Bloom effect and GUI
 
 v2_2
 - LUT array and effects integration
 - Update the GUI and added the dropdown for the LUT styles
 
 v2_1
 - Cleaned up code, comments, etc.
 - Added a glitch effect and slider
 
 v2_0_2
 - Removed Tween logic and replaced it with line segmentation
 - Fixed swatch drawing error
 
 v2_0_1
 - Updated draw logic
 
 v2_0
 - Name change as code continues to merge: Slideshow_v1_5 > Squirrel_v2_0
 - Merged all of the classes & methods from Squirrel
 
 v1_4_1
 - Support for multiple image processing effects at the same time
 - Added sliders and code for brightness & contrast
 - Added dropdown menu to select the filename of an image located in the data folder
 - Merged code that retrieves all images from the directory
 - Takes list of file names and paths and adds them to a dropdown menu
 
 v1_4
 - Added GUI
 - Added slider to adjust the saturation values
 
 v1_3
 - Removed the slideshow timer & replaced it with the ability to cycle through the images with the up/down arrows
 - Added image processing library w/the beginning of the de/saturation logic
 
 v1_2
 - Refactored the code
 
 v1_1
 - Randomly load a random image from data every 5 seconds
 
 v1_0
 - Get and list the paths of files
 - Filter files based on extension
 */

/*
 WISHLIST
 - Merge the CSV code with Squirrel
 - Convert imported image to the CSV colors
 
 PAINTING
 - Paint with new color palette
 - Convert raster to vector
 - Group similar colors together
 - Save as a PDF or SVG file
 
 - Select multiple images from a list to merge
 - Ability to merge multiple images using the Image Processing library
 */
