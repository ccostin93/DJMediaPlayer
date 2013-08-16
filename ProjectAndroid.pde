import select.files.*;

Maxim maxim;
AudioPlayer player1; 
AudioPlayer player2;
float speedAdjust = 1.0; //music&animation speeed
boolean volumeBox = false;
float[] vol = new float[2];
float playTime = 0; //variable used to determine where the music stopped
int frRate = 30; //frameRate
PImage[] TV;
int currTV = 0;
int TVleftMargin = 48;
int TVupMargin = 175;
PImage[] buttons; //vector with buttons images
int buttonDiam = 60; //buttons diameter
PImage[] slider;
int[] sliderYpos = new int[2]; //volume sliders Y position
int sliderXpos; //speed slider X position
boolean randBox = false;
int[] randSlidYpos = new int[3];

PImage[] animation;
float currFrame = 0;
int movH, movW;
int zoom = 0;
boolean video = true; //true - animation, false - audioVisualisation Algorithm

String[] audioFiles; //vector of string with names of audio files
int maxNameLength = 0; //the maximul length of a string in vector

boolean play = false; //is the player1, player2 playing
boolean stop = false; //was stop button pressed?
boolean loop = true;
boolean mute = false;

boolean help = false;

boolean selectedPlayer; //true - player1, false - player2
boolean selectBox = false; //box with audio files
int xSB, ySB; //x,y coordinates of the select box

float magnify = 300; // This is how big we want the rose to be.
float phase = 0; // Phase Coefficient : this is basically how far round the circle we are going to go
float amp = 0; // Amp Coefficient : this is basically how far from the origin we are.
int elements = 128;// This is the number of points and lines we will calculate at once. 1000 is alot actually. 
float threshold = 0.35;// try increasing this if it jumps around too much
int wait=0;
float time = 0;

PImage[] lockScr;
int currLs = 0;
boolean lock = false; //if the screen is locked
boolean prelock = false; //if the user clicked on the designated zone to unlock
int xClick; //remember sa first point of the mouseDragged
String[] slname = {
  "elem", "amp", "mag"
};
int shape = 0;
float xMult = 3, yMult = 1;

String stub, extension, typedText = "";
int numOfPic = 0;
boolean readNum = false;

SelectLibrary files;
void setup()
{
  background(128);

  audioFiles = new String[8]; //vector of string with names of audio files
  audioFiles[0] = "atmos1.wav";
  audioFiles[1] = "bass_snare.wav";
  audioFiles[2] = "beat1.wav";
  audioFiles[3] = "beat2.wav";
  audioFiles[4] = "bells.wav";
  audioFiles[5] = "mybeat.wav";
  audioFiles[6] = "ping.wav";  
  audioFiles[7] = "Other ...";
  for (int i =0; i<audioFiles.length; i++) //calculate the maximul length
  {
    if ( maxNameLength < audioFiles[i].length()) {
      maxNameLength = audioFiles[i].length();
    }
  }

  imageMode(CENTER);
  lockScr = loadImages("Lockscreen/lockscreen", ".jpg", 4);
  TV = new PImage[2];
  TV[0] = loadImage("tv_frame_1.png");
  TV[1] = loadImage("tv_frame_2.png");
  slider = loadImages("Slider/slider", ".png", 10); //load slider images
  buttons = loadImages("Buttons/button", ".png", 12); //load buttons images
  animation = loadImages("Animation_data/movie", ".jpg", 105); //load animation
  movW = animation[0].width; //resize the animation to fit the screen
  if (movW > width) movW = width - TVleftMargin;
  movH = animation[0].height;
  if (movH > height - (buttonDiam+10)) movH = height - (buttonDiam+10) - TVupMargin;

  frameRate(frRate); //set frameRate
  /* if in a second there are 60 frames, the using this we can 
   determine the aproximate millisecond the audio stopped on 
   if we have 354 frames, then we do 354 * 1000/60 and we get the 
   aproximate millisecond when the audio stopped */

  maxim = new Maxim(this);
  player1 = maxim.loadFile("Beats/mybeat.wav");
  player2 = maxim.loadFile("Beats/mybeat.wav");
  vol[0] = vol[1] = 1.0;
  initPlayers();

  for (int i = 0; i < sliderYpos.length; i++)
  {
    sliderYpos[i] = (int)(height - (buttonDiam + 20) - 100 * vol[i]);
  }
  sliderXpos = (int)(50 + 75 * speedAdjust);

  randSlidYpos[0] = (int)map(elements, 50, 1000, 0, 100);
  randSlidYpos[1] = (int)map(amp, -3, 3, 0, 100);
  randSlidYpos[2] = (int)map(magnify, 100, 1000, 0, 100);
  for (int i = 0; i< randSlidYpos.length; i++)
  {
    randSlidYpos[i] = height - (buttonDiam + 70) - randSlidYpos[i];
  }
}

void draw()
{
  colorMode(RGB);
  stroke(1);
  rectMode(CORNER);
  fill(20);
  rect(0, 0, width, height - (buttonDiam + 10));
  imageMode(CENTER);
  if (video) //show movie
  {
    image(animation[(int)currFrame], width/2, (height - (buttonDiam + 10))/2, movW + zoom, movH + zoom);
    image(TV[currTV], width/2, (height - (buttonDiam + 10))/2, width, height - (buttonDiam + 10));
    image(buttons[10], width/2, height - (buttonDiam + 37), 40, 40);
  }
  else //show AudioVisual Algorithm
  {
    audioVisualAlg();
    image(TV[currTV], width/2, (height - (buttonDiam + 10))/2, width, height - (buttonDiam + 10));
    image(buttons[9], width/2, height - (buttonDiam + 37), 40, 40);
  }
  showInfo();
  fill(80);
  noStroke();
  rect(0, height - (buttonDiam + 10), width, 120);
  speedSlid();

  if (play) // is the program playing 
  {
    if (player1.isPlaying() == false || player2.isPlaying() == false)
    {
      play = false;
      playTime = 0;
    }
    else
    {
      playTime++;
      currFrame = currFrame+1*speedAdjust;
      if (currFrame >= animation.length) {
        currFrame = 0;
      }
      image(buttons[1], width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5), buttonDiam, buttonDiam);
    }
  }
  else {
    image(buttons[0], width/2 - 1.5 * buttonDiam - 15, height-(buttonDiam/2 + 5), buttonDiam, buttonDiam);
  }
  showButtons();

  if (selectBox) //choose song
  {
    chooseSong();
  }
  sliderXpos = (int)(50 + 75 * speedAdjust);
  if (volumeBox) //change volume
  {
    for (int i = 0; i < sliderYpos.length; i++)
    {
      sliderYpos[i] = (int)(height - (buttonDiam + 20) - 100 * vol[i]);
    }
    showVolumeBox();
  }
  if (randBox) //change elements, amp, magnify
  {
    randSlidYpos[0] = (int)map(elements, 50, 1000, 0, 100);
    randSlidYpos[1] = (int)map(amp, -3, 3, 0, 100);
    randSlidYpos[2] = (int)map(magnify, 100, 1000, 0, 100);
    for (int i = 0; i< randSlidYpos.length; i++)
    {
      randSlidYpos[i] = height - (buttonDiam + 70) - randSlidYpos[i];
    }
    showRandBox();
  }
  if (help) {
    showHelp();
  }
  if (readNum) {
    stroke(3);
    fill(0, 0, 0, 150);
    rectMode(CENTER);
    rect(width/2, height/2, 50, 25);
    fill(255);
    textSize(19);
    textAlign(CENTER, CENTER);
    text(typedText, width/2, height/2);
  }
  lockScreen();
  if (lock)
  {
    imageMode(CENTER);
    tint(40);
    for (int i = 0; i < lockScr.length; i++)
    {
      if (i != currLs && i > currLs) {
        image(lockScr[i], width/4 * i, -height/10+30, width/5, height/5);
      }
      else if (i != currLs) {
        image(lockScr[i], width/4 * (i+1), -height/10+30, width/5, height/5);
      }
    }
    tint(255);
  }
}

void mousePressed()
{
  xClick = mouseX;
  if (lock)
  {
    if (mouseY <= 30)
    {
      boolean change = false;
      for (int i = 0; i < lockScr.length; i++)
      {
        if (i != currLs && i > currLs && !change) {
          if (mouseX >= width/4 * i - width/10 && 
            mouseX <= width/4 * i + width/10) {
            currLs = i;
            change = true;
            println("> " + currLs);
          }
        }
        else if (i != currLs && !change) {
          if (mouseX >= width/4 * (i+1) - width/10 && 
            mouseX <= width/4 * (i+1) + width/10) {
            currLs = i;
            change = true;
            println("< " + currLs);
          }
        }
      }
      println(currLs);
    }
  }
  /*if (mouseButton == RIGHT)
   {
   currTV++;
   if (currTV >= TV.length) currTV = 0;
   }
   else */
  { /* - Randomizer button for audioVisual / Choose animation for video - */
    if (dist(mouseX, mouseY, width*3/4, height - (buttonDiam + 37)) < 15)
    {
      if (!video) { //for audioVisual
        randBox = true;
        selectBox = false;
        volumeBox = false;
      }
      else { //for animation
        files = new SelectLibrary(this);
        files.selectInput("Select a file to process:", "animSelected");
      }
    }
    /* - Play/Pause button */
    else if (dist(mouseX, mouseY, width/2 - 1.5 * buttonDiam - 15, height - (buttonDiam/2 + 5)) < buttonDiam/2)
    {
      playButton();
    }
    /* - Stop button - */
    else if (dist(mouseX, mouseY, width/2 - 0.5 * buttonDiam - 5, height - (buttonDiam/2 + 5)) < buttonDiam/2)
    {
      stopPlayers();
      selectBox = false;
      volumeBox = false;
      randBox = false;
    }
    /* - Player1 songs list button - */
    else if (dist(mouseX, mouseY, width/2 - 1.5 * buttonDiam - 15 + (2 * (buttonDiam + 10)), height - (buttonDiam/2 + 5)) < (buttonDiam-10)/2)
    {
      selectedPlayer = true;
      selectBox = true;
      xSB = mouseX;
      ySB = mouseY;
      volumeBox = false;
      randBox = false;
    }
    /* - Player2 songs list button - */
    else if (dist(mouseX, mouseY, width/2 - 1.5 * buttonDiam - 15 + (3 * (buttonDiam + 10)), height - (buttonDiam/2 + 5)) < (buttonDiam - 10)/2)
    {
      selectedPlayer = false;
      selectBox = true;
      xSB = mouseX;
      ySB = mouseY;
      volumeBox = false;
      randBox = false;
    }
    /* - Volume Button - */
    else if (dist(mouseX, mouseY, width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)), height - (buttonDiam/2 + 5)) < (buttonDiam - 10)/2)
    {
      if (volumeBox) // double-click on volume button
      {
        volumeBox = false;
        mute = !mute;
        if (mute)
        {
          player1.volume(0);
          player2.volume(0);
        }
      }
      else 
      {
        player1.volume(vol[0]);
        player2.volume(vol[1]);
        mute = false;
        selectBox = false;
        volumeBox = true;
        randBox = false;
      }
    }
    else  if (volumeBox) //volumeBox active
    {
      //if mouseX, mouseY outside box then close volumeBox
      if (mouseX < width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)) - 35 || mouseY < height - (buttonDiam + 70) - 65 ||
        mouseX > width/2 - 1.5 * buttonDiam - 15 + (4 * (buttonDiam + 10)) + 35 || mouseY > height - (buttonDiam + 70) + 65)
      {
        volumeBox = false;
      }
    }
    /* - Video change button - */
    else if (dist(mouseX, mouseY, width/2, height - (buttonDiam + 37)) < 20) 
    {
      video = !video; //change between movie and AudioVisual Algorithm
      selectBox = false;
      volumeBox = false;
      randBox = false;
    }  
    /* - Loop button - */
    else if (dist(mouseX, mouseY, width/2 - 2.5 * buttonDiam - 25, height - (buttonDiam/2 + 5)) < (buttonDiam - 10)/2)
    {
      loop = !loop;
      player1.setLooping(loop);
      player2.setLooping(loop);
      selectBox = false;
      volumeBox = false;
      randBox = false;
    }
    else if (selectBox)
    {
      for (int i = 0; i < audioFiles.length; i++)
      {
        if (mouseX > xSB + 5 && mouseY > ySB + 3 - 21 * (audioFiles.length + 1 - i) + i * 1
          && mouseX < xSB + 5 + 12 * maxNameLength&& mouseY < ySB + 3 - 21 * (audioFiles.length + 1 - i) + i * 1 + 22)
        {
          fill(0, 0, 180, 120);
          rect(xSB + 5, ySB + 3 - 21 * (audioFiles.length + 1 - i) + i * 1, 12 * maxNameLength, 22);

          stopPlayers();
          if (i == 7) {
            files = new SelectLibrary(this);
            files.selectInput("Select a file to process:", "fileSelected");
          }
          else if (selectedPlayer) {
            player1 = maxim.loadFile("Beats/" + audioFiles[i]);
          }
          else {
            player2 = maxim.loadFile("Beats/" + audioFiles[i]);
          }
          initPlayers();
        }
      }
      selectBox = false;
    }
    else {
      selectBox = false;
      volumeBox = false;
      randBox = false;
    }
  }
}

/* --- Doesn't work on Android version --- */
void keyPressed()
{
  String str = "";
  str += key;
  if (readNum) {
    switch(key) {
    case BACKSPACE:
      typedText = typedText.substring(0, max(0, typedText.length()-1));
      break; 
    case ENTER:
    case RETURN:
      // comment out the following two lines to disable line-breaks
      numOfPic = Integer.parseInt(typedText);
      readNum = false;
      stopPlayers();
      animation = loadImages(stub, extension, numOfPic);
      typedText = "";
      break;
    default:
      typedText += key;
    }
  }
  if (str.equals(" ")) {
    playButton();
  }
  else if (str.equals("h")) {
    help = !help;
  }
  else if (str.equals("r"))
  {
    amp = 0; 
    elements = 128;
    magnify = 300;
    vol[0] = vol[1] = 1.0;
    speedAdjust = 1.0;
    player1.speed(speedAdjust);
    player2.speed((player2.getLengthMs()/player1.getLengthMs())*speedAdjust);
  }
  if (!video) {
    if (key == CODED)
    {
      if (keyCode == UP) {
        xMult += 0.5;
      }
      else if (keyCode == DOWN) {
        xMult -= 0.5;
      }
      else if (keyCode == RIGHT) {
        yMult += 0.5;
      }
      else if (keyCode == LEFT) {
        yMult -= 0.5;
      }
    }
    if (str.equals(">") || str.equals(".")) {
      shape++;
      if (shape > 2) shape = 0;
    }
    else if (str.equals("<") || str.equals(",")) {
      shape--;
      if (shape < 0) shape = 2;
    }
  }
  else {
    if (str.equals("+")) {
      zoom += 5;
      if (animation[0].width + zoom > width - TVleftMargin)
        zoom = width - TVleftMargin - animation[0].width;
      else if (animation[0].height + zoom > height - TVupMargin)
        zoom = height - TVupMargin - animation[0].height;
    }
    else if (str.equals("-")) {
      zoom -= 5;
      if (animation[0].width + zoom < (-1) * (width - TVleftMargin)) {
        zoom = (-1)*(width - TVleftMargin) - animation[0].width;
      }
      else if (animation[0].height + zoom < (-1) *(height - TVupMargin)) {
        zoom = (-1) *(height - TVupMargin) - animation[0].height;
      }
    }
  }
}

void mouseDragged() 
{
  if (volumeBox) {
    adjustVolume();
  }
  if (randBox) {
    adjustRand();
  }

  adjustSpeed();

  // LockScreen :D 
  if (!lock && xClick > 0 && xClick < 50) {
    prelock = true;
  }
  else if (lock && xClick < width && xClick > width - 50) {
    prelock = true;
  }
  else {
    prelock = false;
  }
}

void mouseReleased()
{
  if (prelock && mouseX > width/2)
  {
    prelock = false;
    lock = true;
  }
  else if (prelock && mouseX < width/2)
  {
    prelock = false;
    lock = false;
  }
}

