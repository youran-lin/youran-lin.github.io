########################################################
# this is a python code developed by Dr. Youran Lin    #
# adapted from a MatLab code by Dr. Daniel Aalto       #
# to extract 3-dimensional lip measures from FaceApp   #
# the 3 key interested measures are:                   #
# lip opening, spreading, and protrusion in this code  #
# youran.lin@ualberta.ca                               #
########################################################

import numpy
import pandas
import soundfile
from scipy.interpolate import interp1d
from read_praat_tier import read_praat_tier
import sys

# Read filename from command line argument
if len(sys.argv) < 2:
    raise ValueError("Please provide a filename as an argument.")
filename = sys.argv[1]

kinfs = 100
kin = pandas.read_csv(f"{filename}.csv").values

# Read in audio file duration
with soundfile.SoundFile(f"{filename}.wav") as audio_file:
    dur = len(audio_file) / audio_file.samplerate

# Align time and interpolate sampling points
frame = kin[0, 3660]  # time point at the first frame of kinematic data
t = (kin[:, 3660] - frame) / 10**5  # Convert time series to seconds
t -= (t[-1] - dur + 0.112)  # Remove duration differences
tq = numpy.arange(0, dur, 1/kinfs)  # Resampled time series at 100 Hz

# Interpolate kinematic data
kin_interp = interp1d(t, kin, axis=0, bounds_error=False, fill_value='extrapolate')
kinq = kin_interp(tq)

# Extract critical points and coordinates
upper_y = kinq[:, (24*3+1)] # skip 24 points (including 0) and find the Point 24 which is upper lip
upper_z = kinq[:, (24*3+2)]
lower_y = kinq[:, (25*3+1)] # skip 25 points (including 0) and find the Point 25 which is lower lip
lower_z = kinq[:, (25*3+2)]
left_x = kinq[:, (187*3+0)] # skip 187 points (including 0) and find the Point 187 which is left corner
right_x = kinq[:, (636*3+0)] # skip 636 points (including 0) and find the Point 636 which is left corner

# Compute critical measures
spread = right_x - left_x
opening = upper_y - lower_y
protrusion = (upper_z + lower_z) / 2

# Save waveforms
def save_wav(data, name):
    soundfile.write(f"{filename}_{name}.wav", data, 100)

save_wav(spread, "spread")
save_wav(opening, "opening")
save_wav(protrusion, "protrusion")

# Read TextGrid data
intervals, labels = read_praat_tier(f"{filename}.TextGrid", "1")

# Compute measures at centroids
centroids = numpy.round((intervals[:, 0] + intervals[:, 1]) / 2, 2)
centroids_indices = (centroids * 100).astype(int)
startings = numpy.round(intervals[:,0],2)
startings_indices = (startings * 100).astype(int)
endings = numpy.round(intervals[:,1],2)
endings_indices = (endings * 100).astype(int)

target_duration = intervals[:, 1] - intervals[:, 0]

spread_starting = spread[startings_indices]
opening_starting = opening[startings_indices]
protrusion_starting = protrusion[startings_indices]

spread_centroid = spread[centroids_indices]
opening_centroid = opening[centroids_indices]
protrusion_centroid = protrusion[centroids_indices]

spread_ending = spread[endings_indices]
opening_ending = opening[endings_indices]
protrusion_ending = protrusion[endings_indices]

spread_average = numpy.array([numpy.mean(spread[startings_indices:endings_indices]) for startings_indices, endings_indices in zip(startings_indices, endings_indices)])
opening_average = numpy.array([numpy.mean(opening[startings_indices:endings_indices]) for startings_indices, endings_indices in zip(startings_indices, endings_indices)])
protrusion_average = numpy.array([numpy.mean(protrusion[startings_indices:endings_indices]) for startings_indices, endings_indices in zip(startings_indices, endings_indices)])


# Save to CSV
data = pandas.DataFrame({
    'label': labels,
    'duration': target_duration,
    'centroid': centroids,
    'spread_average': spread_average,
    'opening_average': opening_average,
    'protrusion_average': protrusion_average,
    'spread_starting': spread_starting,
    'spread_centroid': spread_centroid,
    'spread_ending': spread_ending,
    'opening_starting': opening_starting,
    'opening_centroid': opening_centroid,
    'opening_ending': opening_ending,
    'protrusion_starting': protrusion_starting,
    'protrusion_centroid': protrusion_centroid,
    'protrusion_ending': protrusion_ending
})
data.to_csv(f"{filename}_output.csv", index=False)