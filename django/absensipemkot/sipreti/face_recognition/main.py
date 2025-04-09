'''
Main program
@Author: David Vu

To execute simply run:
main.py

To input new user:
main.py --mode "input"

'''

import cv2
from .align_custom import AlignCustom
from .face_feature import FaceFeature
from .mtcnn_detect import MTCNNDetect
from .tf_graph import FaceRecGraph
import argparse
import sys
import json
import time
import numpy as np
from urllib.request import urlopen
TIMEOUT = 10 #10 seconds
from numpy import array
import os
from django.conf import settings


path_dataset = settings.MEDIA_ROOT+"/assets/dataset/"

def create_empty_dataset(path):
    dir = os.path.dirname(path)
    if not os.path.exists(dir):
        os.makedirs(dir)
    if not os.path.exists(path):
        f = open(path,'w+')
        f.write("{}")
    else:
        os.remove(path)
        f = open(path,'w+')
        f.write("{}")
    
'''
Description:
Images from Video Capture -> detect faces' regions -> crop those faces and align them 
    -> each cropped face is categorized in 3 types: Center, Left, Right 
    -> Extract 128D vectors( face features)
    -> Search for matching subjects in the dataset based on the types of face positions. 
    -> The preexisitng face 128D vector with the shortest distance to the 128D vector of the face on screen is most likely a match
    (Distance threshold is 0.6, percentage threshold is 70%)
    
'''
def verify_face(url_image,id_pegawai):
    FRGraph = FaceRecGraph();
    MTCNNGraph = FaceRecGraph();
    aligner = AlignCustom();
    extract_feature = FaceFeature(FRGraph)
    face_detect = MTCNNDetect(MTCNNGraph, scale_factor=2); 
    
    # print("get photo...")
    # vs = cv2.VideoCapture(0); #get input from webcam
    detect_time = time.time()
    req = urlopen(url_image)
    arr = np.asarray(bytearray(req.read()), dtype=np.uint8)
    frame = cv2.imdecode(arr, -1) # 'Load it as it is'
    #u can certainly add a roi here but for the sake of a demo i'll just leave it as simple as this
    try:
        # print("get landmark")
        rects, landmarks = face_detect.detect_face(frame,80);#min face size is set to 80x80
    except:
        # print("gagal get landmark")
        return False
    aligns = []
    positions = []

    for (i, rect) in enumerate(rects):
        aligned_face, face_pos = aligner.align(160,frame,landmarks[:,i])
        if len(aligned_face) == 160 and len(aligned_face[0]) == 160:
            aligns.append(aligned_face)
            positions.append(face_pos)
        else: 
            print("Align face failed") #log  
    # print("reconigzed")      
    # print(len(aligns))
    if(len(aligns) > 0):
        features_arr = extract_feature.get_features(aligns)
        recog_data = findPeople(features_arr,positions,id_pegawai)
        return recog_data
'''
 Data Structure:
{
"Person ID": {
    "Center": [[128D vector]],
    "Left": [[128D vector]],
    "Right": [[128D Vector]]
    }
}
This function basically does a simple linear search for 
^the 128D vector with the min distance to the 128D vector of the face on screen
'''
def findPeople(features_arr, positions, id_pegawai, thres = 0.6, percent_thres = 70):
    '''
    :param features_arr: a list of 128d Features of all faces on screen
    :param positions: a list of face position types of all faces on screen
    :param thres: distance threshold
    :return: person name and percentage
    '''

    # print(path_dataset+id_pegawai)
    f = open(path_dataset+id_pegawai+'.txt','r')
    data_set = json.loads(f.read());
    returnRes = [];
    for (i,features_128D) in enumerate(features_arr):
        result = "Unknown";
        smallest = sys.maxsize
        for person in data_set.keys():
            person_data = data_set[person][positions[i]];
            for data in person_data:
                distance = np.sqrt(np.sum(np.square(data-features_128D)))
                if(distance < smallest):
                    smallest = distance;
                    result = person;
        percentage =  min(100, 100 * thres / smallest)
        if percentage <= percent_thres :
            result = "Unknown"
            print("unknown")
            return False
        returnRes.append((result,percentage))
        print("label:"+result)
        print("percentage:"+str(percentage))

        if(result!=id_pegawai):
            return False
    return True    

def add_face(url_image,file_name):
    FRGraph = FaceRecGraph();
    MTCNNGraph = FaceRecGraph();
    aligner = AlignCustom();
    extract_feature = FaceFeature(FRGraph)
    face_detect = MTCNNDetect(MTCNNGraph, scale_factor=2); 

    # print("adding face")
    new_name = file_name; #ez python input()
    create_empty_dataset(path_dataset+file_name+'.txt')
    f = open(path_dataset+file_name+'.txt','r');
    data_set = json.loads(f.read());
    person_imgs = {"Left" : [], "Right": [], "Center": []};
    person_features = {"Left" : [], "Right": [], "Center": []};
    no = 1;
    for(image) in url_image:
        # print(no)
        no += 1
        try:
            req = urlopen(image)
        except:
            continue
        arr = np.asarray(bytearray(req.read()), dtype=np.uint8)
        frame = cv2.imdecode(arr, -1) # 'Load it as it is'
        # This will contain the an array of feature vectors of the images
        try:
            # print("get landmark")
            rects, landmarks = face_detect.detect_face(frame, 80);  # min face size is set to 80x80
        except:
        #   print("gagal get landmark")
          return False
        
        if(len(rects)>0):
            for (i, rect) in enumerate(rects):
                aligned_frame, pos = aligner.align(160,frame,landmarks[:,i]);
                if len(aligned_frame) == 160 and len(aligned_frame[0]) == 160:
                    person_imgs[pos].append(aligned_frame)
        else:
            # print("No Face")
            return False
        

    for pos in person_imgs: #there r some exceptions here, but I'll just leave it as this to keep it simple
        person_features[pos] = [np.mean(extract_feature.get_features(person_imgs[pos]),axis=0).tolist()]
    data_set[new_name] = person_features;
    f = open(path_dataset+file_name+'.txt', 'w');
    f.write(json.dumps(data_set))
    return True

