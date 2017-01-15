/*
* opticalFlow.cpp
*
*  Created on: Mar 16, 2016
*/

/*************************************** Includes ***************************************/
// General
#include <iostream>
#include <pthread.h>
#include <time.h>
#include <vector>
// OpenCV
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/videoio/videoio.hpp"
#include "opencv2/highgui/highgui.hpp"
// Our files
#include "Globals.h"
#ifdef  QT
#include "mainwindow.h"
#endif
#include "opticalflowfunctions.h"

/*************************************** Namespaces ***************************************/
using namespace cv;
using namespace std;
/*************************************** Global Variables *********************************/
/* import global variables */
locationStruct currLocation;
locationStruct lastFlowStep;
locationStruct lastFlowStepSections[4];
locationStruct gpsLocation;
int init=0;

/********************************* Main Optical Flow Function *****************************/
/* calculate the location of the UAV according the input frame from the camera and the angles of the body*/
//int opticalFlow(int source, MainWindow &w){
void OpticalFlow(){

	int tempX = 0;
	int tempY = 0;
	locationStruct filteredLocation;
	locationStruct prevLocation;
	
	//filter
	filteredLocation.x = 0.0;
	filteredLocation.y = 0.0;
	prevLocation.x = 0.0;
	prevLocation.y = 0.0;
	float alpha = 0.5;

	/* define matrices */
	Mat cameraMatrix = (Mat_<double>(3, 3) <<
		3.33277197938593e+03, 0, 2.06813063483159e+03,
		0, 3.33832169430243e+03, 1.15961268140133e+03,
		0, 0, 1
		);
	Mat processedFrame, origFrame;
	//    Mat flow, uflow;
	UMat gray, prevgray;

	// Create grid for opticalflow
	vector<Point2f> globalGrid;
	createGrid(globalGrid, WIDTH_RES, HEIGHT_RES, 20);

#ifdef VIDEO_ACTIVE
	namedWindow("flow", WINDOW_NORMAL);
#endif

	currLocation.x = 0;
	currLocation.y = 0;
	locationStruct predLocation;
	double rovX, rovY;		// range of view in both axis

	/*  compare every two frames												***/
	/******************************************************************************/
	// the distorted function can't open the first frame- so ignore it
	//for (int i = 0; i < 2; i++);
	// for each frame calculate optical flow
	// take out frame- still distorted
	while (!end_of_file){
		origFrame = currentframe;

		// convert to gray
		cvtColor(origFrame, processedFrame, COLOR_BGR2GRAY, CV_8U);

		//apply perspective
		rotateImage(processedFrame, gray, eulerFromSensors.roll, eulerFromSensors.pitch, 0, 0, 0, 1, cameraMatrix.at<double>(0, 0),
			cameraMatrix.at<double>(0, 2), cameraMatrix.at<double>(1, 2));

		if (!prevgray.empty())
		{
#ifdef VIDEO_ACTIVE
			// show camera view
			imshow("flow", prevgray);
#endif

			// calculate flow per section - each section in different thread
			sectionInfo topLeft, topRight;
			sectionInfo bottomLeft, bottomRight;

			topLeft.frameSection = UMat(gray, Range(0.2*HEIGHT_RES, HEIGHT_RES*0.55), Range(0.2*WIDTH_RES, WIDTH_RES*0.55));
			topLeft.prevFrameSection = UMat(prevgray, Range(0.2*HEIGHT_RES, HEIGHT_RES*0.55), Range(0.2*WIDTH_RES, WIDTH_RES*0.55));
			topLeft.index = 0;
			topLeft.grid = globalGrid;

			topRight.frameSection = UMat(gray, Range(0.2*HEIGHT_RES, HEIGHT_RES*0.55), Range(WIDTH_RES*0.45, WIDTH_RES*0.8));
			topRight.prevFrameSection = UMat(prevgray, Range(0.2*HEIGHT_RES, HEIGHT_RES*0.55), Range(WIDTH_RES*0.45, WIDTH_RES*0.8));
			topRight.index = 1;
			topRight.grid = globalGrid;

			bottomLeft.frameSection = UMat(gray, Range(0.45*HEIGHT_RES, HEIGHT_RES*0.8), Range(0.2*WIDTH_RES, WIDTH_RES*0.55));
			bottomLeft.prevFrameSection = UMat(prevgray, Range(0.45*HEIGHT_RES, HEIGHT_RES*0.8), Range(0.2*WIDTH_RES, WIDTH_RES*0.55));
			bottomLeft.index = 2;
			bottomLeft.grid = globalGrid;

			bottomRight.frameSection = UMat(gray, Range(0.45*HEIGHT_RES, HEIGHT_RES*0.8), Range(WIDTH_RES*0.45, WIDTH_RES*0.8));
			bottomRight.prevFrameSection = UMat(prevgray, Range(0.45*HEIGHT_RES, HEIGHT_RES*0.8), Range(WIDTH_RES*0.45, WIDTH_RES*0.8));
			bottomRight.index = 3;
			bottomRight.grid = globalGrid;

			pthread_t topLeft_thread, topRight_thread;
			pthread_t bottomLeft_thread, bottomRight_thread;
			pthread_create(&topLeft_thread, NULL, OpticalFlowPerSection, &topLeft);
			pthread_create(&topRight_thread, NULL, OpticalFlowPerSection, &topRight);
			pthread_create(&bottomLeft_thread, NULL, OpticalFlowPerSection, &bottomLeft);
			pthread_create(&bottomRight_thread, NULL, OpticalFlowPerSection, &bottomRight);

			if (!init)
				cout << "initializing..." << endl;
			pthread_join(topLeft_thread, NULL);
			pthread_join(topRight_thread, NULL);
			pthread_join(bottomLeft_thread, NULL);
			pthread_join(bottomRight_thread, NULL);
			init = 1;
			// merge the outputs
			lastFlowStep.x = (lastFlowStepSections[0].x + lastFlowStepSections[1].x + lastFlowStepSections[2].x + lastFlowStepSections[3].x) / 4;
			lastFlowStep.y = (lastFlowStepSections[0].y + lastFlowStepSections[1].y + lastFlowStepSections[2].y + lastFlowStepSections[3].y) / 4;

			// calculate range of view - 2*tan(fov/2)*distance
#ifdef SONAR_ACTIVE
			// currently dont take the median, take the last sample
			// FOV_X = 63.65
			// FOV_Y = 44.96
			rovX = 2 * 0.6206305052 * 100 * distanceSonar*cos(eulerFromSensors.roll)*cos(eulerFromSensors.pitch);// 2 * tan(xfov/2) * dist(cm)
			rovY = 2 * 0.4138046654 * 100 * distanceSonar*cos(eulerFromSensors.roll)*cos(eulerFromSensors.pitch);// 2 * tan(yfov/2) * dist(cm)
#else
			double dist = 87 * (cos(eulerFromSensors.roll)*cos(eulerFromSensors.pitch));             // distance from surface in cm
			rovX = 2 * 0.6206305052*dist; 		// 2 * tan(xfov/2) * dist
			rovY = 2 * 0.4138046654*dist;		// 2 * tan(yfov/2) * dist
#endif
			// If euler speed changed - calculate and apply x,y prediction
			if (eulerSpeedChanged.load())
			{
				eulerSpeedChanged.store(false);

				// DeltaX = Delta_Pitch * (Wx / fov_x)
				// DeltaY = Delta_Roll * (Wy / fox_y)
				predLocation.x = ((eulerFromSensors.pitch - prevEulerFromSensors.pitch)*(180 / PI)*WIDTH_RES) / 63.65;
				predLocation.y = ((eulerFromSensors.roll - prevEulerFromSensors.roll)*(180 / PI)*HEIGHT_RES) / 44.96;

				//cout << "Sonar with factor: " << distanceSonar << endl;

				// calculate final x, y location (apply prediction)
				locationStruct locationCorrectionAfterYaw;
				locationCorrectionAfterYaw.x = ((lastFlowStep.x - predLocation.x) / WIDTH_RES)*rovX;
				locationCorrectionAfterYaw.y = ((lastFlowStep.y - predLocation.y) / HEIGHT_RES)*rovY;

#ifdef YAW_ACTIVE
				// Correct direction using yaw
				locationCorrectionAfterYaw = calculateNewLocationByYaw(locationCorrectionAfterYaw);
#endif

				// Update current location
				currLocation.x -= locationCorrectionAfterYaw.x;
				currLocation.y += locationCorrectionAfterYaw.y;

				// Update angle correction graph
				tempX += lastFlowStep.x;
				tempY += lastFlowStep.y;
#ifdef QT
				w.AngleCorrectionUpdate(tempX, tempY, -predLocation.x, predLocation.y);
#endif
				tempX = 0;
				tempY = 0;
			}
			else{

				// calculate final x, y location
				locationStruct locationCorrectionAfterYaw;
				locationCorrectionAfterYaw.x = (lastFlowStep.x / WIDTH_RES)*rovX;
				locationCorrectionAfterYaw.y = (lastFlowStep.y / HEIGHT_RES)*rovY;

#ifdef YAW_ACTIVE
				// Correct direction using yaw
				locationCorrectionAfterYaw = calculateNewLocationByYaw(locationCorrectionAfterYaw);
#endif
				// calculate final x, y location
				currLocation.x -= locationCorrectionAfterYaw.x;
				currLocation.y += locationCorrectionAfterYaw.y;
				tempX += lastFlowStep.x;
				tempY += lastFlowStep.y;
				
			}

			// Update Location Plot
#ifdef QT
			w.UpdatePlot(currLocation.x, currLocation.y);
#endif
			
			filteredLocation.x = alpha * filteredLocation.x + (1 - alpha) * currLocation.x;
			filteredLocation.y = alpha * filteredLocation.y + (1 - alpha) * currLocation.y;
 			
			cout << offset << "," << currLocation.x << "," << currLocation.y << endl;
			//cout << offset << "," << filteredLocation.x << "," << filteredLocation.y << endl;
		}

		/*break conditions
		if(waitKey(1)>=0)
		break;
		if(end_run)
		break;
		*/
		std::swap(prevgray, gray);
	}
	// close video
#ifdef VIDEO_ACTIVE
	destroyWindow("flow");
#endif

	return ;
}
