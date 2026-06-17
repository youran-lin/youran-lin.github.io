########################################################
# this is a python code developed by Dr. Youran Lin    #
# to convert the FaceApp video  file to wav file       #
# youran.lin@ualberta.ca                               #
########################################################

import os
import sys
from moviepy import *

def convert_mp4_to_wav(input_path):
    # Ensure the input path exists
    if not os.path.exists(input_path):
        print(f"Error: Directory '{input_path}' does not exist.")
        return
    
    # Get all MP4 files in the directory
    mp4_files = [f for f in os.listdir(input_path) if f.endswith(".MP4")]
    
    if not mp4_files:
        print("No MP4 files found in the directory.")
        return
    
    # Output directory for WAV files
    output_path = os.path.join(input_path, "converted_wav")
    os.makedirs(output_path, exist_ok=True)
    
    for mp4_file in mp4_files:
        input_file = os.path.join(input_path, mp4_file)
        output_file = os.path.join(output_path, os.path.splitext(mp4_file)[0] + ".wav")
        
        print(f"Converting {mp4_file} to WAV...")
        
        try:
            # Load and convert audio
            audio_clip = AudioFileClip(input_file)
            audio_clip.write_audiofile(output_file, ffmpeg_params=["-ac", "1"])
            audio_clip.close()
            print(f"Saved: {output_file}")
        except Exception as e:
            print(f"Error processing {mp4_file}: {e}")
    
    print("Conversion complete!")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python script.py <directory_path>")
    else:
        convert_mp4_to_wav(sys.argv[1])