/*
AdjustPixels class by Dr. Woohoo!

Applies a range of image processing effects to the main image.
*/

class AdjustPixels {

  AdjustPixels() {
  }

  void update() {
    adjustedImg = Saturation.apply(origImg, satIntensity);
    adjustedImg = Brightness.apply(adjustedImg, briIntensity);
    adjustedImg = Contrast.apply(adjustedImg, contIntensity);
    adjustedImg = Glitch.apply(adjustedImg, glitchIntensity);
    adjustedImg = LUT.apply(adjustedImg, lookuptables[currentLutIndex]);
    adjustedImg = Bloom.apply(adjustedImg, bloomIntensity);
    adjustedImg = Lights.apply(adjustedImg, lightsIntensity);
    image(adjustedImg, 0, 0);
  }
}
