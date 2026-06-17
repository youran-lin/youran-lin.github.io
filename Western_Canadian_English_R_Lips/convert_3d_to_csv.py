########################################################
# this is a python code developed by Dr. Daniel Aalto  #
# to convert the FaceApp txt file to tabulat csv file  #
# daniel.aalto@ualberta.ca                             #
########################################################

import sys
import os
import socket

#import ray
#ray.init(num_cpus=4)
#import modin.pandas as pd

import datetime as dt
import numpy as np
from math import pi
import csv
import timeit

startT = timeit.timeit()

# Define the directory where the .txt files are located
input_directory = sys.argv[1]  # Replace with your directory path
output_directory = os.path.join(input_directory, "converted_csv")
os.makedirs(output_directory, exist_ok=True)

# Get all .txt files from the directory
txt_files = [f for f in os.listdir(input_directory) if f.endswith('.txt')]

# Loop through all .txt files
for processfilename in txt_files:
    fullfile = os.path.join(input_directory, processfilename)
    # savefilename = processfilename.replace('.txt', '.csv')
    fullsavepath = os.path.join(output_directory, os.path.splitext(processfilename)[0]+".csv")

    print("Processing: " + processfilename)

    # Read data file
    row = []        #create empty list                         
    rows = list()   #return a list for rows

    col_headers = list()    #return a list for column header 
    vertex_headers = list() #return a list for vertex header

    for s in range(1220):
        x = "v"+str(s) + "_x"  #header for vertex x
        y = "v"+str(s) + "_y"  #header for vertex y 
        z = "v"+str(s) + "_z"  #header for vertex z

        col_headers.append(x) # append the x column header
        col_headers.append(y) # append the y column header
        col_headers.append(z) # append the z column header

    col_headers.append("TimeStamp") # append the header for TimeStamp
    col_headers.append("Trial")     # append the header for Trial 

    # Read data file
    with open(fullfile, mode='r') as face_data:  #open the .txt file 
        print("Loading... " + processfilename)
        data = face_data.readline()   #reading a line from the .txt file 
        data = data.split(">") #filter the > and put that into the next row 
        index = 0
        print("Parsing... " + processfilename)
        for mesh in data:
            mesh = mesh.replace(":",",") #replace : to ,
            mesh = mesh.replace("~",",") #replace ~ to ,
            mesh = mesh.replace("<","")  #replace ~ to whitespace
            mesh = mesh.replace("t,","") #replace t to whitespace
            mesh = mesh.replace("trial,","") #replace t to whitespace
            mesh = mesh.replace("m,","") #replace t to whitespace
            mesh = mesh.split(",")

            vindex = 0  #vertex start at 0 
            for v in mesh:
                if (len(row) <= 3662):  #if length of the row is less or equal to 3662 (1220*3+2) 
                    row.append(v)
                    if (len(row) != 3662 and len(mesh) == vindex):  # if row is not equal to 3661 
                        row = []    
                    if (len(row) == 3662): # if row is equal to 3662 (finsihing read one entire row)
                        rows.append(row)  #append the 3660 vertices and 1 timestamp and 1 trial, and 16 elements for projection matrix 
                        row = []
                vindex = vindex + 1      #index adds 1 


    #Create csv-formatted data
    print("Reformatting to csv...")

    print(len(rows))
    print(len(row))
    #print(rows)

    #Write the csv file
    with open(fullsavepath,'w',newline='') as f:
    	writer = csv.writer(f)
    	writer.writerow(col_headers)
    	writer.writerows(rows)

    #print("Creating df... " + processfilename)

    # Add data to df
    #df = pd.DataFrame(rows,columns=col_headers)

    #df[col_headers] = df[col_headers].astype(float)

    #print("Converting df to pickle... ")
    # Save as pickle for post processing
    #df.to_pickle(fullsavepath + '.pickle')

    #print("Converting df to csv... ")

    # Write csv 
    #df.to_csv(fullsavepath)

    print("COMPLETE!!!")

endT=timeit.timeit()
print(endT-startT)
