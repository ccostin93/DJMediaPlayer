void audioVisualAlg()
{
  colorMode(HSB);
  float pow1 = player1.getAveragePower();
  float pow2 = player2.getAveragePower();
  if ((pow1+pow2)/2 >threshold && wait < 0) {
    phase += pow1 * 6 + pow2 * 4;
    wait += 10;
  }
  wait--;
  time += 0.01;
  float spacing = TWO_PI/elements; // this is how far apart each 'node' will be - study it. 
  pushMatrix();
  translate(width*0.5, height*0.5);// we translate the whole sketch to the centre of the screen, so 0,0 is in the middle.
  noFill();
  strokeWeight(2);
  for (int i = 0; i < elements;i++) {
    stroke((i*2)%255, 255, 255, 150);
    pushMatrix();
    rotate(spacing*i*phase+time*3);
    translate(sin(spacing*amp*i)*magnify, 0);
    rotate(-(spacing*i*phase));
    rotate(i);
    //noStroke();
    //fill((i*2)%255, 255, 255, 5);
    if (shape == 0) {
      ellipse(0, 0, i*(pow1*10)*xMult, i*(pow2*10)*yMult);
    }
    else if (shape == 1) {
      rect(0, 0, i*(pow1*10)*xMult, i*(pow2*10)*yMult);
    }
    else {
      line(0, 0, i*(pow1*10)*xMult, -i*(pow2*10)*yMult);
    }
    popMatrix();
    stroke(255, 0, 0);
  }
  popMatrix();
}

void speedSlid()
{
  // Speed slider
  textAlign(CENTER);
  textSize(12);
  fill(255);
  text("Speed", 25, height - (buttonDiam + 37) + 5);
  image(slider[6], 50, height - (buttonDiam + 37) + 5, 9, 9);
  image(slider[7], 200, height - (buttonDiam + 37) + 5, 9, 9);
  imageMode(CORNER);
  image(slider[8], 53, height - (buttonDiam + 37) - 5 + 5, sliderXpos - 53, 9);
  image(slider[9], sliderXpos, height - (buttonDiam + 37) - 5 + 5, 197 - sliderXpos, 9);
  imageMode(CENTER);
  image(slider[5], sliderXpos, height - (buttonDiam + 37) + 5, 21, 21);
}

void stopPlayers()
{
  player1.stop();
  player2.stop();
  stop = true;
  if (play) play = !play;
  playTime = 0;
  currFrame = 0;
  selectBox = false;
  volumeBox = false;
  time = 0;
}

void adjustVolume()
{
  int x = (int)(width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)));
  for (int i = 0; i < 2; i++) 
  {
    if (mouseX >= x-17 + i*34-11 && mouseX <= x-17+i*34+11 &&
      mouseY > sliderYpos[i] - 11 && mouseY < sliderYpos[i] + 11)
    {
      int my = constrain(mouseY, height - (buttonDiam+20) - 100, height - (buttonDiam+20));
      sliderYpos[i] = my;
      vol[0] = (height - (buttonDiam+20) - sliderYpos[0])*0.01;
      player1.volume(vol[0]);
      vol[1] = (height - (buttonDiam+20) - sliderYpos[1])*0.01;
      player2.volume(vol[1]);
    }
  }
}

void adjustSpeed()
{
  int y = (int)(height - (buttonDiam + 37) - 5);
  if (mouseX >= sliderXpos - 11 && mouseX <= sliderXpos + 11 &&
    mouseY >= y - 11 && mouseY <= y + 11)
  {
    int mx = constrain(mouseX, 50, 200);
    sliderXpos = mx;
    speedAdjust = (float)(sliderXpos - 50) / 75;
    player1.speed(speedAdjust);
    player2.speed((player2.getLengthMs()/player1.getLengthMs())*speedAdjust);
  }
}

void initPlayers()
{
  player1.setAnalysing(true);
  player1.setLooping(loop);
  player1.speed(speedAdjust);
  player1.volume(vol[0]);
  player2.setAnalysing(true);
  player2.setLooping(loop);
  player2.speed((player2.getLengthMs()/player1.getLengthMs())*speedAdjust);
  player1.volume(vol[1]);
}

void showButtons()
{
  if (player1.isPlaying() == false || player2.isPlaying() == false) {
    image(buttons[0], width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5), buttonDiam, buttonDiam);
  }
  else {
    image(buttons[1], width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5), buttonDiam, buttonDiam);
  }
  image(buttons[2], width/2 - 1.5 * buttonDiam - 15 + (buttonDiam + 10), height - (buttonDiam/2 + 5), buttonDiam, buttonDiam);
  for (int i = 2; i < 4; i++) //create the buttons
  {
    image(buttons[i+1], width/2 - 1.5 * buttonDiam - 15 + (i * (buttonDiam + 10)), height - (buttonDiam/2 + 5), buttonDiam - 10, buttonDiam - 10);
  }
  image(buttons[8], width/2 - 2.5 * buttonDiam - 25, height - (buttonDiam/2 + 5), buttonDiam - 10, buttonDiam - 10);

  /* Volume Button Image */
  if ((vol[0] + vol[1]) > 1.3 && !mute) {
    image(buttons[5], width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5), buttonDiam - 10, buttonDiam - 10);
  }
  else if ((vol[0] + vol[1]) > 0 && !mute) {
    image(buttons[6], width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5), buttonDiam - 10, buttonDiam - 10);
  }
  else {
    image(buttons[7], width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5), buttonDiam - 10, buttonDiam - 10);
  }
  if (!video) {
    image(buttons[11], width*3/4, height - (buttonDiam + 37), 30, 30);
  }
  else {
    image(buttons[3], width*3/4, height - (buttonDiam + 37), 30, 30);
  }
}

void chooseSong()
{
  textAlign(LEFT);
  textSize(20);
  stroke(220);
  strokeWeight(3);
  fill(150);
  int overEdge = 0;
  if (xSB + 5 +  12 * maxNameLength > width - 5)
  {
    overEdge = xSB + 5 +  12 * maxNameLength - width + 5;
  }
  rect(xSB + 5 - overEdge, ySB - 21 * (audioFiles.length + 1) + 3, 12 * maxNameLength, 21 * audioFiles.length + 3);
  for (int i = 0; i < audioFiles.length; i++)
  {
    fill(255);
    text(audioFiles[i], xSB + 8 - overEdge, ySB + 3 - 21 * (audioFiles.length - i)); 
    if (mouseX > xSB + 5 - overEdge && mouseY > ySB + 3 - 21 * (audioFiles.length + 1 - i) + i * 1
      && mouseX < xSB + 5 - overEdge + 12 * maxNameLength&& mouseY < ySB + 3 - 21 * (audioFiles.length + 1 - i) + i * 1 + 22)
    {
      strokeWeight(1);
      stroke(200);
      fill(0, 0, 180, 80);
      rectMode(CORNER);
      rect(xSB + 5 - overEdge, ySB + 3 - 21 * (audioFiles.length + 1 - i) + i * 1, 12 * maxNameLength, 21);
    }
  }
}

void adjustRand()
{
  int x = (int)(width*3/4);
  for (int i = -1; i <= 1; i++) 
  {
    if (mouseX >= x+i*34-11 && mouseX <= x+i*34+11 &&
      mouseY > randSlidYpos[i+1] - 11 && mouseY < randSlidYpos[i+1] + 11)
    {
      int my = constrain(mouseY, height - (buttonDiam + 70) - 100, height - (buttonDiam + 70));
      randSlidYpos[i+1] = my;
      if ( i == -1) {
        elements = (int)map(height - (buttonDiam + 70) - randSlidYpos[0], 0, 100, 50, 1000);
      }
      else if (i == 0) {
        amp = map(height - (buttonDiam + 70) - randSlidYpos[1], 0, 100, -3, 3);
        println("amp = " + amp);
      }
      else if (i == 1) {
        magnify = map(height - (buttonDiam + 70) - randSlidYpos[2], 0, 100, 100, 1000);
        println("magnify = " + magnify);
      }
    }
  }
}

void showRandBox()
{
  rectMode(CENTER);
  stroke(220);
  strokeWeight(3);
  fill(150);
  rect(width*3/4, height - (buttonDiam + 125), 105, 140);

  for (int i = -1; i < 2; i++)
  {
    int load = height - (buttonDiam + 75) - randSlidYpos[i+1];
    pushMatrix();
    translate(width*3/4 + i * 34, height - (buttonDiam + 70));
    textSize(13);
    fill(255);
    textAlign(CENTER, CENTER);
    text(slname[i+1], 0, -118);
    rotate(-PI/2);
    imageMode(CENTER);
    image(slider[1], 0, 0);
    image(slider[2], 100, 0);
    imageMode(CORNER);
    image(slider[3], 4, -slider[3].height/2, load, slider[3].height);
    image(slider[4], load, -slider[4].height/2, 100 - load, slider[4].height);    
    popMatrix();
    imageMode(CENTER);
    image(slider[0], width*3/4 + i * 34, randSlidYpos[i+1]);
  }
}

void showVolumeBox()
{
  rectMode(CENTER);
  stroke(220);
  strokeWeight(3);
  fill(150);
  rect(width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam + 70), 70, 130);

  pushMatrix();
  translate(width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)) - 17, height - (buttonDiam + 20));
  rotate(-PI/2);
  imageMode(CENTER);
  image(slider[1], 0, 0);
  image(slider[2], 100, 0);
  imageMode(CORNER);
  image(slider[3], 4, -slider[3].height/2, 100*vol[0], slider[3].height);
  image(slider[4], 100*vol[0], -slider[4].height/2, 100 - 100*vol[0], slider[4].height);
  popMatrix();

  pushMatrix();
  translate(width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)) + 17, height - (buttonDiam + 20));
  rotate(-PI/2);
  imageMode(CENTER);
  image(slider[1], 0, 0);
  image(slider[2], 100, 0);
  imageMode(CORNER);
  image(slider[3], 4, -slider[3].height/2, 100*vol[1], slider[3].height);
  image(slider[4], 100*vol[1], -slider[4].height/2, 100 - 100*vol[1], slider[4].height);
  popMatrix();

  imageMode(CENTER);
  image(slider[0], width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)) - 17, sliderYpos[0]);
  image(slider[0], width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)) + 17, sliderYpos[1]);
}

void lockScreen()
{
  imageMode(CENTER);
  if (prelock)
  {
    tint(50);
    image(lockScr[currLs], mouseX - width/2 + 10, height/2, width, height);
  }
  else if (lock) {
    tint(255);
    image(lockScr[currLs], width/2, height/2, width, height);
  }
  tint(255);
}

void playButton()
{
  if (!play) 
  {
    if (stop == false)
    {
      float sp2 = (player2.getLengthMs()/player1.getLengthMs())*speedAdjust;
      player1.cue((int)(playTime * 1000/frRate));
      player2.cue((int)(playTime * 1000/frRate * sp2));
    }
    else
    {
      player1.cue(0);
      player2.cue(0);
      stop = false;
    }
    player1.play();
    player2.play();
  }
  else
  {
    player1.stop();
    player2.stop();
  }
  play = !play;
  selectBox = false;
  volumeBox = false;
  randBox = false;
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
    println("User selected " + selection.getAbsolutePath());
    if (selectedPlayer) {
      player1 = maxim.loadFile(selection.getAbsolutePath());
    }
    else {
      player2 = maxim.loadFile(selection.getAbsolutePath());
    }
  }
}

void animSelected(File selection)
{
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
    String file = selection.getAbsolutePath();
    println("User selected " + file);
    extension = file.substring(file.length()-4);
    println("extension = " + extension);
    stub = file.substring(0, file.length() - 5);
    println("stub = " + stub);
    readNum = true;
    movW = animation[0].width; //resize the animation to fit the screen
    if (movW > width) movW = width - TVleftMargin;
    movH = animation[0].height;
    if (movH > height - (buttonDiam+10)) movH = height - (buttonDiam+10) - TVupMargin;
  }
}

void showHelp()
{
  rectMode(CORNER);
  stroke(3);
  fill(0, 0, 0, 150);
  rect(width/2 - 145, height/4 - 25, 290, 184);
  fill(255);
  textSize(20);
  textAlign(CENTER);
  text("Help", width/2, height/4);
  textSize(15);
  text("Right Click - change TV frame", width/2, height/4 + 18);
  textSize(17);
  text("Animation", width/2, height/4 + 43);
  textSize(15);
  text("+/- - zoom in/out", width/2, height/4 + 56);
  textSize(17);
  text("AudioVisual", width/2, height/4 + 81);
  textSize(15);
  text("UP/DOWN - increase/decrease xMult", width/2, height/4 + 99);
  text("LEFT/RIGHT - increase/decrease yMult", width/2, height/4 +117);
  text("</> - change shapes", width/2, height/4 + 135);
  text("r - reset to initial values", width/2, height/4 + 153);
  fill(0);
  line(width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5), width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5) - 20);
  line(width/2 - 1.5 * buttonDiam - 15 + (buttonDiam + 10), height - (buttonDiam/2 + 5), width/2 - 1.5 * buttonDiam - 10 + (buttonDiam + 10), height - (buttonDiam/2 + 5) - 20);
  line(width/2 - 1.5 * buttonDiam - 15 + (2 * (buttonDiam + 10)), height - (buttonDiam/2 + 5), width/2 - 1.5 * buttonDiam - 15 + (2 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) -20);
  line(width/2 - 1.5 * buttonDiam - 15 + (3 * (buttonDiam + 10)), height - (buttonDiam/2 + 5), width/2 - 1.5 * buttonDiam - 15 + (3 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) -20);
  line(width/2 - 2.5 * buttonDiam - 25, height - (buttonDiam/2 + 5), width/2 - 2.5 * buttonDiam - 30, height - (buttonDiam/2 + 5) -20);
  line(width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5), width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) - 20);
  line(width*3/4, height - (buttonDiam + 37), width*3/4, height - (buttonDiam + 37) - 20);
  line(width/2, height - (buttonDiam + 37), width/2, height - (buttonDiam + 37) - 20);
  rectMode(CENTER);
  stroke(3);
  fill(0, 0, 0, 150);
  rect(width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5) - 30, 85, 20);
  rect(width/2 - 1.5 * buttonDiam - 15 + (buttonDiam + 10) + 5, height - (buttonDiam/2 + 5) - 30, 40, 20);
  rect(width/2 - 1.5 * buttonDiam - 15 + (2 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) - 30, 53, 20);
  rect(width/2 - 1.5 * buttonDiam - 15 + (3 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) - 30, 53, 20);
  rect(width/2 - 2.5 * buttonDiam - 25 - 5, height - (buttonDiam/2 + 5) - 30, 50, 20);
  rect(width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) - 30, 60, 20);
  if (video) {
    rect(width*3/4, height - (buttonDiam + 37) - 30, 78, 20);
  }
  else {
    rect(width*3/4, height - (buttonDiam + 37) - 30, 88, 20);
  }
  rect(width/2, height - (buttonDiam + 37) - 30, 140, 20);
  textAlign(CENTER, CENTER);
  fill(255);
  text("Play/Pause", width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5) - 30);
  text("Stop", width/2 - 1.5 * buttonDiam - 15 + (buttonDiam + 10) + 5, height - (buttonDiam/2 + 5) - 30);
  text("Player1", width/2 - 1.5 * buttonDiam - 15 + (2 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) - 30);
  text("Player2", width/2 - 1.5 * buttonDiam - 15 + (3 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) - 30);
  text("Repeat", width/2 - 2.5 * buttonDiam - 25 - 5, height - (buttonDiam/2 + 5) - 30);
  text("Volume", width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5) - 30);
  if (video) {
    text("Animation", width*3/4, height - (buttonDiam + 37) - 30);
  }
  else {
    text("Randomizer", width*3/4, height - (buttonDiam + 37) - 30);
  }
  text("Visualizer changer", width/2, height - (buttonDiam + 37) - 30);
}

void showInfo()
{
  fill(255);
  textSize(15);
  textAlign(CORNER);
  if (loop) {
    text("repeat on", 35, 70);
  }
  else {
    text("repeat off", 35, 70);
  }
  if (!video)
  {
    text("elements = " + elements, 35, 88);
    text("amplitude = " + amp, 35, 106);
    text("magnify = " + magnify, 35, 124);
    if (shape == 0) {
      text("shape = " + "ellipse", 35, 142);
    }
    else if (shape == 1) {
      text("shape = " + "rectangle", 35, 142);
    }
    else text("shape = " + "line", 35, 142);
    text("xMult = " + xMult, 35, 160);
    text("yMult = " + yMult, 35, 178);
  }
}

