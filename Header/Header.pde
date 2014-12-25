

/* @pjs preload="logo-header-front.png"; */
/* @pjs preload="logo-header-back.png"; */
/* @pjs pauseOnBlur="true"; */

ParticleSystem mSys;
PImage mLogo, mBack;
PVector mCenter, mMouse;
boolean mIsTriggered=false;
float mTriggerFrame=0;
int mLogoPalletNum=0;
float[] mFrameRates;
int mPreWidth=0; 
int mPreHeight=0;

int mInitMouseX, mInitMouseY;
int mGlobalAlpha=24;
int mPulseSpeed =1;
int mPulseDir=-1;
int mSincePulse=30;
void setup()
{
  mTriggerFrame=0;
  mIsTriggered = false;
  mFrameRates = new float[90];
  mPreHeight=0;
  mPreWidth=0;
  frameRate(30);

  size(window.innerWidth, window.innerHeight);
  background(0);
  mLogo = loadImage("logo-header-front.png");
  mBack = loadImage("logo-header-back.png");

  colorMode(HSB, 360, 100, 100, 100);
  imageMode(CENTER);
  ellipseMode(CENTER);
  mCenter= new PVector(width/2, height/2);
  mMouse = new PVector(0, 0);

  mLogoPalletNum = (int) random(0, 4);
  mSys = new ParticleSystem(400, mCenter);
  Particle part = new Particle(mCenter);
  part.setCol(color(205, 66, 100));
  part.setVel( new PVector(0, 0));
  mSys.addParticle(part);

  background(0);
  for (int i=0; i<mFrameRates.length; i++) mFrameRates[i]=30;

  var hex= {
    "#276276", "#467E7E", "#ED8813", "#6F4FA0"
  } 
  ;
  document.getElementById("tab").firstElementChild.style.backgroundColor= hex[mLogoPalletNum];

  mInitMouseX= mouseX;
  mInitMouseY= mouseY;
}

void draw()
{
  //Resizes the window when the size changes
  if (mPreWidth!= width || mPreHeight != height) {
    mCenter.set(width/2, height/2);
    setup();
  }
  //
  mPreWidth= width; 
  mPreHeight = height;

  Particle part= mSys.mParts[mSys.mMaxPointsToDisplay-1];
  if (mIsTriggered) {
    part.setPos(mMouse);
  } else {
    int scatterWidth=10000; 
    int scatterHeight=100000;
    while ( scatterWidth * scatterWidth + scatterHeight * scatterHeight> (mLogo.width/4) * (mLogo.width/4)) {
      scatterWidth = random( -mLogo.width/4, mLogo.width/4);
      scatterHeight = random( -mLogo.width/4, mLogo.width/4);
    }
    scatterWidth=0;
    scatterHeight=0;
    PVector pos = new PVector(mCenter.x + scatterWidth, mCenter.y + scatterHeight);
    part.setPos(pos);
  }
  noStroke();
  //strokeWeight(10);
  fill(0, 42);

  background(0, 0, 0);
  //blendMode(ADD);
  if (mouseX != mInitMouseX || mouseY != mInitMouseY) {
    mMouse.x = mouseX;
    mMouse.y= mouseY;
  }
  mSys.live();
  mSys.damp(.99);
  mSys.sortByDistance();

  //mSys.displayAll();
  mSys.displayAllCurve();
  //mSys.displayCirclesOnPoints();
  //mSys.displayPoint();

  //if the mouse is near the logo's center, EXPLODE!!!
  PVector centerMouse = PVector.sub(mCenter, mMouse);
  if (!mIsTriggered && pow(centerMouse.x, 2) + pow(centerMouse.y, 2)<pow(mLogo.width/2, 2) ) {
    mIsTriggered=true;
    mTriggerFrame=frameCount;
    //mSys.shatter(10);
    mSys.shatter(8, 8);
    //mSys.shatter(20,15);
  }
  //
  
  //explosion animation
  if (frameCount-mTriggerFrame>=10 && frameCount-mTriggerFrame<=23)
  {
    mSys.damp(.8);
  }
  if (frameCount-mTriggerFrame<20) {
    mSys.damp(1.02);
  }
  //
  //Control mGlobalAlpha, it is responsible for pulsing the logo's opacity
  if (!mIsTriggered && mSincePulse>25) {
    if (mGlobalAlpha-mPulseSpeed*4 < 0 && mPulseDir==-1) {
      mPulseDir =1;
    }
    if (mGlobalAlpha+mPulseSpeed*4>100 && mPulseDir==1) {
      mPulseDir = -1;
      mSincePulse=0;
    }
    if (mPulseDir == 1) {
      mGlobalAlpha += mPulseSpeed*4;
    } else {
      mGlobalAlpha -= mPulseSpeed*4;
    }
    //      mGlobalAlpha %=100;
  } else {
    mGlobalAlpha=100;
  }
  //
  
  mSincePulse++;
  fill(0);
  noStroke();
  if (!mIsTriggered) ellipse(mCenter.x, mCenter.y, 5, 5);
  tint(hue(mSys.pallet[mLogoPalletNum]), saturation(mSys.pallet[mLogoPalletNum])*1.5, brightness(mSys.pallet[mLogoPalletNum]), mGlobalAlpha);
  image(mBack, mCenter.x, mCenter.y, mBack.width, mBack.height);
  tint(0, 0, 100, mGlobalAlpha);
  image(mLogo, mCenter.x, mCenter.y, mLogo.width, mLogo.height);
  //println(frameRate);
  
  //Control the number of the particels
  //keep them as many as is possible, the FPS should be more than 25
  mFrameRates[frameCount%mFrameRates.length] = frameRate;
  float averageFrameRate = 0;
  for (int i=0; i<mFrameRates.length; i++) averageFrameRate += mFrameRates[i];
  averageFrameRate /= (float) mFrameRates.length;
  if (!mIsTriggered && averageFrameRate<25 && mSys.mMaxPointsToDisplay>44) {
    mSys.mMaxPointsToDisplay-=8;
  }
  if (mIsTriggered && averageFrameRate<25 && mSys.mMaxPointsToDisplay>44) {
    mSys.mMaxPointsToDisplay-=4;
  }
  if (averageFrameRate>25 && averageFrameRate<28 && mSys.mMaxPointsToDisplay>44) {
    mSys.mMaxPointsToDisplay-=2;
  }
  if (averageFrameRate>=28 && frameCount%5==0 && mSys.mMaxPointsToDisplay+2<mSys.mParts.length) {
    mSys.mMaxPointsToDisplay+=1;
  }
  //
}

void keyPressed()
{
  if (key==' ') {
    mSys.shatter(5);
  }
}

void keyReleased()
{
  if (key==' ') {
    mSys.shatter(5);
  }
}


void mouseMoved()
{
  if (mIsTriggered && pmouseX>0 && pmouseX<width && pmouseY>0 && pmouseY<height && frameCount-mTriggerFrame>30) {
    float rad= dist(mouseX, mouseY, pmouseX, pmouseY);
    mSys.shatter(4, mMouse, rad);
    //mSys.shatter(5, mMouse, rad, PVector.sub(new PVector(pmouseX, pmouseY), mMouse));
  }
}

void mouseDragged()
{
  if (mIsTriggered && pmouseX>0 && pmouseX<width && pmouseY>0 && pmouseY<height && frameCount-mTriggerFrame>30) {
    float rad= dist(mouseX, mouseY, pmouseX, pmouseY);
    mSys.shatter(4, mMouse, rad);
  }
}


class Attractor
{

  PVector     mPos;
  float       mMass;


  Attractor(PVector aPos, float aMass)
  {
    mPos= new PVector( aPos.x, aPos.y);
    mMass= aMass;
  }

  void setPos(PVector aPos)
  {
    mPos.x = aPos.x;
    mPos.y= aPos.y;
  }

  void setMass(float aMass)
  {
    mMass = aMass;
  }
}

class Particle
{

  PVector     mPos, mInitPos;
  color       mCol, mInitCol;
  PVector     mVel;
  PVector     mAcc;
  ArrayList   mHist;
  int         mMaxHistSize;
  int         mLife;
  float       mSeed;
  Attractor   mInitAttractor;
  float       mFlickerPeriod;
  float       mSize;

  Particle(PVector aPos)
  {
    colorMode(HSB, 360, 100, 100, 100);
    mPos= new PVector (aPos.x, aPos.y);
    mInitPos = new PVector(aPos.x, aPos.y);
    mHist = new ArrayList();
    mVel = new PVector (random(-1, 1), random(-1, 1));
    mAcc=new PVector(0, 0);
    mMaxHistSize=1;
    mSeed=random(-100, 100);
    mCol= color(50, 100, 50);
    mInitCol= color(50, 100, 50);
    mInitAttractor = new Attractor(mInitPos, 50);

    mFlickerPeriod = random(3000, 6000);

    mSize = random(5, 20);
  }

  void setPos( PVector aPos)
  {
    mPos.x = aPos.x;
    mPos.y= aPos.y;
  }

  void setCol( color aCol)
  {
    mCol=aCol;
    mInitCol=aCol;
  }

  void setVel( PVector aVel)
  {
    mVel.x = aVel.x;
    mVel.y= aVel.y;
  }

  void display()
  {
    noStroke();
    fill(mCol, 50);
    ellipse(mPos.x, mPos.y, 5, 5);
  }

  void display(float aSize)
  {
    strokeWeight(aSize);
    noFill();
    stroke(mCol, 50);
    point(mPos.x, mPos.y);
    strokeWeight(1);
  }

  void displayPoint()
  {
    noFill();
    stroke(mCol);
    strokeWeight(3);
    point(mPos.x, mPos.y);
    strokeWeight(1);
  }

  void displayImage(PImage aImg)
  {
    tint(0, 0, 100);
    pushMatrix();
    translate(mPos.x, mPos.y);
    //scale(mSize/aImg.width);
    image(aImg, aImg.width, aImg.height);
    popMatrix();
  }

  void displayHist()
  {

    noFill();
    beginShape();
    for (int i=0; i<mHist.size ()-3; i+=3) {
      PVector pos = (PVector) mHist.get(i);

      if (random(0, 1)<.3) stroke(mCol, map(i, 0, mMaxHistSize, 0, 20));
      else stroke(0);
      vertex(pos.x, pos.y);
      pos = (PVector) mHist.get(i+1);
      vertex(pos.x, pos.y);
      pos = (PVector) mHist.get(i+2);
      vertex(pos.x, pos.y);
    }
    endShape();
    // popMatrix();
  }

  void live()
  {
    mLife++;

    mVel.add(mAcc);
    mPos.add(mVel);
    mAcc.mult(0);


    while (mHist.size ()>=mMaxHistSize) mHist.remove(0);
    mHist.add(new PVector(mPos.x, mPos.y));
    mHist.add(new PVector(mPos.x+random(-5, 5), mPos.y+random(-5, 5)));
    mHist.add(new PVector(mPos.x+random(-5, 5), mPos.y+random(-5, 5)));


    if (mPos.x>width-mVel.x ) mVel.x*=-1; 
    if (mPos.y>height-mVel.y)  mVel.y*=-1;
    if (mPos.x<0) mVel.x*=-1;
    if (mPos.y<0) mVel.y*=-1;
  }

  void getAttractedBy (Attractor aAttractor, int aMode)
  {
    if (aMode==0) {
      PVector dir= PVector.sub(aAttractor.mPos, mPos);
      float dist = dir.mag();
      dist= min(100, max(20, dist));
      float m = aAttractor.mMass*2 / (dist*dist) ;
      // float m = aAttractor.mMass/100 ;
      dir.normalize();
      dir.mult(m);
      mAcc.add(dir);
      //mVel.add(new PVector(random(-.5, .5), random(-.5, .5)));
      //mVel.add(new PVector(map(noise((mSeed + frameCount)*.02), 0, 1, -1, 1), map(noise((mSeed + frameCount)*.005), 0, 1, -1, 1)));
    }
    if (aMode==1) {
      PVector dir= PVector.sub(aAttractor.mPos, mPos);
      float dist = dir.mag();
      dist= min(100, max(20, dist));
      dir.normalize();
      float m = aAttractor.mMass*2/ dist  ;
      dir.mult(m);
      mVel=dir;
      //mVel.add(new PVector(random(-.5, .5), random(-.5, .5)));
      mVel.add(new PVector(map(noise((mSeed + frameCount)*.02), 0, 1, -5, 5), map(noise((mSeed + frameCount)*.005), 0, 1, -3, 3)));
    }
  }

  void goToInitPos()
  {

    PVector dir= PVector.sub(mInitAttractor.mPos, mPos);
    float dist = dir.mag();
    if (dist>=20) {
      dist= min(100, max(20, dist));
      dir.normalize();
      float m = mInitAttractor.mMass*2/ dist  ;
      dir.mult(m);
      mVel=dir;
    } else
    {
      mPos=mInitPos;
    }
    //mVel.add(new PVector(random(-.5, .5), random(-.5, .5)));
    //mVel.add(new PVector(map(noise((mSeed + frameCount)*.02), 0, 1, -5, 5), map(noise((mSeed + frameCount)*.005), 0, 1, -3, 3)));
  }

  void flicker()
  {

    float alph= map(millis() % mFlickerPeriod, 0, mFlickerPeriod, 0, PI);
    alph=sin(alph)*100;
    float magni= mVel.mag();
    magni+=.15;
    alph*=magni;
    // alph = map(alph,0,100,20,100);
    colorMode(HSB, 360, 100, 100, 100);
    mCol= color( hue(mInitCol), saturation(mInitCol), brightness(mInitCol), alph );
  }
}

class ParticleSystem
{

  Particle[]       mParts;
  int[]            mDistData;
  boolean          mHasShattered=false;
  color[]          pallet;
  color            mLogoFrontColor;
  int              mMaxPointsToDisplay;
  int              mCounter;

  void makePallet()
  {
    colorMode(HSB, 360, 100, 100, 100);
    pallet = new color[4];
    //pallet[4] = color(144, 72, 55);//Green
    pallet[0] = color(195, 66, 46);//Blue
    pallet[1] = color(180, 44, 49);//Light Blue
    pallet[2] = color(32, 91, 92);//Orange
    pallet[3] = color(263, 50, 62);//Purple

    mLogoFrontColor = color(0, 1, 65);
  }

  ParticleSystem(int aNum)
  {
    makePallet();
    mParts = new Particle[aNum];
    mDistData = new int[aNum];
    PVector center= new PVector(width/2, height/2);
    for (int i=0; i<aNum; i++) {
      Particle part = new Particle(new PVector(random(0, width), random(0, height)));
      part.setCol(color(223, 70, 100));
      part.setVel( new PVector(0, 0));
      mParts[i]= part;
      mDistData[i] = (int) random(0, aNum);
    }
    mMaxPointsToDisplay=aNum;
  }

  ParticleSystem(PVector aPos)
  {
    makePallet();
    mParts = new Particle[400];
    mDistData = new int[400];
    PVector center= new PVector(width/2, height/2);
    mMaxPointsToDisplay=1;
    mCounter=0;
  }

  ParticleSystem(int aNum, PVector aPos)
  {
    makePallet();
    mParts = new Particle[aNum];
    mDistData = new int[aNum];

    PVector center= new PVector(width/2, height/2);
    for (int i=0; i<aNum; i++) {
      int scatterWidth=10000; 
      int scatterHeight=100000;
      while ( scatterWidth * scatterWidth + scatterHeight * scatterHeight> (mLogo.width/4) * (mLogo.width/4)) {
        scatterWidth = random( -mLogo.width/4, mLogo.width/4);
        scatterHeight = random( -mLogo.width/4, mLogo.width/4);
      }
      scatterWidth=0; 
      scatterHeight=0;
      PVector pos = PVector.add(aPos, new PVector(scatterWidth, scatterHeight));
      Particle part = new Particle(pos );
      //part.setCol(color(205, 66, 100));
      color col = pallet[ (int) mLogoPalletNum];
      if (random(0.0, 1.0) >0.5) {
        part.setCol(color(hue(mLogoFrontColor), saturation(mLogoFrontColor), random(0, 100)));
      } else {
        part.setCol(color(hue(col), random(saturation(col), 100), brightness(col)));
      }
      part.setVel( new PVector(0, 0));
      mParts[i]= part;
      //      mDistData.add(random(0,aNum-5));
    }
    mMaxPointsToDisplay=aNum;
  }


  void addParticle(Particle aPart)
  {
    mParts[mMaxPointsToDisplay-1] = aPart;
    mDistData[mDistData.length-1] = 5;
  }

  void addParticle()
  {
    if (mCounter<400) {
      Particle part = new Particle(new PVector(width/2, height/2));
      //part.setCol(color(205, 66, 100));
      color col = pallet[ (int) mLogoPalletNum];
      // if (random(0.0, 1.0) >0.5) {
      //   part.setCol(color(hue(mLogoFrontColor), saturation(mLogoFrontColor), map(random(0, 100), 0, 100, brightness(mLogoFrontColor), 100)));
      // } else {
      //   part.setCol(color(hue(col), map(random(0, 100), 0, 100, saturation(col), 100), brightness(col)));
      // }
      if (random(0.0, 1.0) >0.5) {
        part.setCol(color(hue(mLogoFrontColor), saturation(mLogoFrontColor), random(0, 100)));
      } else {
        part.setCol(color(hue(col), random(saturation(col), 100), brightness(col)));
      }
      part.setVel( new PVector(0, 0));
      mParts[mCounter]= part;
      mCounter++;
      mMaxPointsToDisplay++;
      //      mDistData.add(random(0,aNum-5));
    }
  }
  void sortByDistance()
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      mDistData[i]=0;
      Particle mainPart = mParts[i];
      float dist=10000000;
      int   index=-1;
      for (int j=0; j<mMaxPointsToDisplay; j++) {
        Particle part = mParts[j];
        int index2=-1;
        if (i>j) {
          index2 = mDistData[j];
        }

        if (j!=i && index2!=i) {
          float distance = sqrt ( pow((mainPart.mPos.x-part.mPos.x), 2)+ pow((mainPart.mPos.y-part.mPos.y), 2));
          if (dist>distance) {
            index=j;
            dist= distance;
          }
        }
      }

      mDistData[i] = index;
      //mDistData.add((int)random(0, mParts.size()-1));
    }
  }

  void display()
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.display();
    }
  }

  void display(float aSize)
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.display(aSize);
    }
  }

  void displayPoint()
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.displayPoint();
    }
  }

  void displayImage(PImage aImg)
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.displayImage(aImg);
    }
  }

  void displayHist()
  {

    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.displayHist();
    }
  }

  void displayAll()
  {
    //    for (int i=0; i<mParts.size(); i++) {
    //      Particle part = (Particle) mParts.get(i);
    //      part.displayPoint();
    //    }

    for (int i=0; i<mMaxPointsToDisplay; i++) {
      int nearestPartID = mDistData[i];
      int secondNearestPartID = mDistData[nearestPartID];
      Particle part =  (Particle) mParts[i];
      if (i<mMaxPointsToDisplay-1) part.displayPoint();
      Particle part2 =  mParts[nearestPartID];
      Particle part3 = mParts[secondNearestPartID];
      float howClose = dist(part.mPos.x, part.mPos.y, part.mInitPos.x, part.mInitPos.y);
      howClose += dist(part2.mPos.x, part2.mPos.y, part2.mInitPos.x, part2.mInitPos.y);
      howClose /=2;

      //beginShape();
      beginShape(TRIANGLES);
      strokeWeight(1);
      //if (howClose<20) stroke(part.mCol, howClose);
      //else stroke(part.mCol);
      PVector pos = (PVector) part.mHist.get(0);
      PVector pos2 = (PVector) part2.mHist.get(0);
      PVector pos3 = (PVector) part3.mHist.get(0);
      if (i<mMaxPointsToDisplay-1) {
        stroke(part.mCol);
        fill(part.mCol, alpha(part.mCol)*.2);
        //curveVertex((pos.x+pos2.x)/2+random(-3,3), (pos.y+ pos2.y)/2+random(-3,3));
        vertex(pos.x, pos.y);
        //bezierVertex(pos3.x+random(-10,10), pos3.y+random(-10,10),pos.x+random(-10,10), pos.y+random(-10,10),pos3.x, pos3.y);
        stroke(part2.mCol);
        fill(part2.mCol, alpha(part2.mCol)*.2);
        vertex(pos2.x, pos2.y);
        //bezierVertex(pos.x+(i%50)/100, pos.y+(i%50)/100,pos2.x+(i%50)/100, pos2.y+i/100,pos.x, pos.y);
        stroke(part3.mCol);
        fill(part3.mCol, alpha(part3.mCol)*.2);
        vertex(pos3.x, pos3.y);
        // bezierVertex(pos2.x+(i%50)/100, pos2.y+(i%50)/100,pos3.x+(i%50)/100, pos3.y+(i%50)/100,pos2.x, pos2.y);
      } else {
        stroke(part.mCol, 600/howClose);
        fill(part.mCol, alpha(part.mCol)*.2*600/howClose);
        vertex(pos.x, pos.y);
        stroke(part2.mCol, 600/howClose);
        fill(part2.mCol, alpha(part2.mCol)*.2*600/howClose);
        vertex(pos2.x, pos2.y);
        stroke(part3.mCol, 600/howClose);
        fill(part3.mCol, alpha(part3.mCol)*.2*600/howClose);
        vertex(pos3.x, pos3.y);
      }
      endShape();
    }
  }

  void displayAllCurve()
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      int nearestPartID = mDistData[i];
      int secondNearestPartID = mDistData[nearestPartID];
      Particle part =  (Particle) mParts[i];
      if (i<mMaxPointsToDisplay-1) part.displayPoint();
      Particle part2 =  mParts[nearestPartID];
      Particle part3 = mParts[secondNearestPartID];
      float howClose = dist(part.mPos.x, part.mPos.y, part.mInitPos.x, part.mInitPos.y);
      howClose += dist(part2.mPos.x, part2.mPos.y, part2.mInitPos.x, part2.mInitPos.y);
      howClose /=2;

      //beginShape();
      beginShape();
      strokeWeight(1);
      //if (howClose<20) stroke(part.mCol, howClose);
      //else stroke(part.mCol);
      PVector pos = (PVector) part.mHist.get(0);
      PVector pos2 = (PVector) part2.mHist.get(0);
      PVector pos3 = (PVector) part3.mHist.get(0);
      if (i<mMaxPointsToDisplay-1) {
        stroke(part.mCol);
        fill(part.mCol, alpha(part.mCol)*.2);
        //curveVertex((pos.x+pos2.x)/2+random(-3,3), (pos.y+ pos2.y)/2+random(-3,3));
        curveVertex(pos.x, pos.y);
        curveVertex(pos.x, pos.y);
        //bezierVertex(pos3.x+random(-10,10), pos3.y+random(-10,10),pos.x+random(-10,10), pos.y+random(-10,10),pos3.x, pos3.y);
        stroke(part2.mCol);
        fill(part2.mCol, alpha(part2.mCol)*.2);
        curveVertex(pos2.x, pos2.y);
        //bezierVertex(pos.x+(i%50)/100, pos.y+(i%50)/100,pos2.x+(i%50)/100, pos2.y+i/100,pos.x, pos.y);
        stroke(part3.mCol);
        fill(part3.mCol, alpha(part3.mCol)*.2);
        curveVertex(pos3.x, pos3.y);
        curveVertex(pos3.x, pos3.y);
        // bezierVertex(pos2.x+(i%50)/100, pos2.y+(i%50)/100,pos3.x+(i%50)/100, pos3.y+(i%50)/100,pos2.x, pos2.y);
      } else {
        stroke(part.mCol, 600/howClose);
        fill(part.mCol, alpha(part.mCol)*.2*600/howClose);
        curveVertex(pos.x, pos.y);
        curveVertex(pos.x, pos.y);
        stroke(part2.mCol, 600/howClose);
        fill(part2.mCol, alpha(part2.mCol)*.2*600/howClose);
        curveVertex(pos2.x, pos2.y);
        stroke(part3.mCol, 600/howClose);
        fill(part3.mCol, alpha(part3.mCol)*.2*600/howClose);
        curveVertex(pos3.x, pos3.y);
        curveVertex(pos3.x, pos3.y);
      }
      endShape();
    }


    //endShape();
  }
  //endShape();
  void displayCirclesOnPoints()
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      int nearestPartID = mDistData[i];
      int secondNearestPartID = mDistData[nearestPartID];
      Particle part =  (Particle) mParts[i];
      if (i<mMaxPointsToDisplay-1) part.displayPoint();
      Particle part2 =  mParts[nearestPartID];
      Particle part3 = mParts[secondNearestPartID];
      float howClose = dist(part.mPos.x, part.mPos.y, part.mInitPos.x, part.mInitPos.y);
      howClose += dist(part2.mPos.x, part2.mPos.y, part2.mInitPos.x, part2.mInitPos.y);
      howClose /=2;

      //beginShape();
      //beginShape();
      strokeWeight(1);
      //if (howClose<20) stroke(part.mCol, howClose);
      //else stroke(part.mCol);
      PVector pos = (PVector) part.mHist.get(0);
      PVector pos2 = (PVector) part2.mHist.get(0);
      PVector pos3 = (PVector) part3.mHist.get(0);

      float yDelta_a = pos2.y - pos.y;
      float xDelta_a = pos2.x - pos.x;
      float yDelta_b = pos3.y - pos2.y;
      float xDelta_b = pos3.x - pos2.x;
      PVector center = new PVector(0, 0);
      float radius = 0.0;
      ellipseMode(CENTER);

      if (abs(xDelta_a) <= 0.00000001 && abs(yDelta_b) <= 0.00000001) {
        center.set( 0.5 * (pos2.x+pos3.x), 0.5 * (pos.y+pos2.y));
        radius = dist(center.x, center.y, pos.x, pos.y);
      } else if (xDelta_a !=0 && xDelta_b != 0) {
        float aSlope= yDelta_a/ xDelta_a;
        float bSlope= yDelta_b/ xDelta_b;
        if (abs(aSlope- bSlope) <= 0.0000001) {
          break;
        }

        center.x = (aSlope* bSlope* (pos.y- pos3.y) + bSlope*(pos.x + pos2.x) - aSlope*(pos2.x+pos3.x) ) / (2* (bSlope-aSlope) );
        center.y = -1 * (center.x - (pos.x+ pos2.x)/2)/aSlope + (pos.y+pos2.y)/2;
        radius = dist( center.x, center.y, pos.x, pos.y);
      }

      if (i<mMaxPointsToDisplay-1) {
        stroke(part.mCol);
        fill(part.mCol, alpha(part.mCol)*.2);
        //curveVertex((pos.x+pos2.x)/2+random(-3,3), (pos.y+ pos2.y)/2+random(-3,3));
        ellipse (center.x, center.y, radius*2, radius*2);
      } else {
        stroke(part.mCol, 600/howClose);
        fill(part.mCol, alpha(part.mCol)*.2*600/howClose);
        ellipse (center.x, center.y, radius*2, radius*2);
      }
    }
  }

  void live()
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.live();
      part.flicker();
    }
  }

  void getAttractedBy (Attractor aAttractor, int aMode)
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.getAttractedBy(aAttractor, aMode);
    }
  }

  void goToInitPos()
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      PVector initPos=part.mInitPos;
      PVector dir = PVector.sub(initPos, part.mPos);
      float magni= dir.mag();
      dir.normalize();
      dir.mult(.01);
      //dir.add(new PVector(random(-1,1),random(-1,1)));
      part.mVel.add(dir);
    }
  }

  void shatter(float aMaxSpeed)
  {
    mHasShattered=true;
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      part.setVel( new PVector(random(-aMaxSpeed, aMaxSpeed), random(-aMaxSpeed, aMaxSpeed)));
    }
  }
  void shatter(float aMaxSpeedX, float aMaxSpeedY)
  {
    mHasShattered=true;
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      float rand1= 1000;
      float rand2= 1000;
      while ( rand1*rand1 + rand2*rand2 >= aMaxSpeedX*aMaxSpeedX) {
        rand1 = random(-aMaxSpeedX, aMaxSpeedX);
        rand2 = random(-aMaxSpeedY, aMaxSpeedY);
      }
      part.setVel( new PVector(rand1, rand2));
    }
  }

  void shatter(float aMaxSpeed, PVector aCenter, float aRad)
  {
    mHasShattered=true;
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      PVector dir= PVector.sub(aCenter, part.mPos );

      if ( dir.mag()<aRad) {
        // part.setVel( new PVector(random(-aMaxSpeed, aMaxSpeed), random(-aMaxSpeed, aMaxSpeed)));
        PVector randVec= new PVector(random(-aMaxSpeed, aMaxSpeed), random(-aMaxSpeed, aMaxSpeed));
        dir.normalize();
        //        dir.x*=randVec.x;
        //        dir.y*=randVec.y;
        dir.mult(random(-aMaxSpeed, aMaxSpeed));
        part.setVel(dir);
      }
    }
  }

  void shatter(float aMaxSpeed, PVector aCenter, float aRad, PVector aDir)
  {
    mHasShattered=true;
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];

      if ( PVector.sub(aCenter, part.mPos ).mag()<aRad) {
        // part.setVel( new PVector(random(-aMaxSpeed, aMaxSpeed), random(-aMaxSpeed, aMaxSpeed)));
        PVector dir=new PVector(aDir.x, aDir.y);
        dir.normalize();
        //        dir.x*=randVec.x;
        //        dir.y*=randVec.y;
        dir.mult(random(0, aMaxSpeed));
        part.setVel(dir);
      }
    }
  }

  void damp(float aVal)
  {
    for (int i=0; i<mMaxPointsToDisplay; i++) {
      Particle part = mParts[i];
      PVector vel = new PVector(part.mVel.x, part.mVel.y);
      float magni = vel.mag();
      magni*=aVal;
      vel.normalize();
      vel.mult(magni);
      part.setVel( vel);
    }
  }
}
