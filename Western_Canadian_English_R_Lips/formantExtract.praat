########################################################################################################################
#
# This script extracts duration, F1, F2, F3, F4, F5, and 10-point formants from all labeled phonemes in a Sound file.
# It assumes phonemes are on Tier 1.
# It outputs this information to a file named "..._formant.csv"
#
# To run this script, open a Sound and TextGrid in Praat and have them selected.
#
# The base script was originally created by following the workshop by Joey Stanley & Lisa Lipani:
# http://joeystanley.com/downloads/191002-formant_extraction.html
# Joey Stanley
# Tuesday, October 1, 2019
# Main Libary, UGA campus, Athens, GA, USA
#
# This script is adapted by Youran Lin
# Tuesday, February 11, 2025
# Youran Lin, Ph.D., R.SLP., University of Alberta
# youran.lin@ualberta.ca
#
########################################################################################################################

form: "fill gender and directory path"
	choice: "Gender", 2
		option: "Female"
		option: "Male"
endform

writeInfoLine: "Extracting formants..."

# Extract the names of the Praat objects
thisSound$ = selected$("Sound")
thisTextGrid$ = selected$("TextGrid")

# Extract the number of intervals in the phoneme tier
select TextGrid 'thisTextGrid$'
numberOfIntervals = Get number of intervals: 1  
appendInfoLine: "There are ", numberOfIntervals, " intervals."

# Create the Formant Object
select Sound 'thisSound$'
if gender$ = "Male"
	formantCeiling = 5000
else
	formantCeiling = 5500
endif

To Formant (burg)... 0 5 formantCeiling 0.025 50

# Create the output file and write the first line.
outputPath$ = thisSound$+"_formants.csv"
writeFileLine: "'outputPath$'", "time,label,duration,F1,F2,F3,F4,F5,F1_1,F1_2,F1_3,F1_4,F1_5,F1_6,F1_7,F1_8,F1_9,F1_10,F2_1,F2_2,F2_3,F2_4,F2_5,F2_6,F2_7,F2_8,F2_9,F2_10,F3_1,F3_2,F3_3,F3_4,F3_5,F3_6,F3_7,F3_8,F3_9,F3_10,F4_1,F4_2,F4_3,F4_4,F4_5,F4_6,F4_7,F4_8,F4_9,F4_10,F5_1,F5_2,F5_3,F5_4,F5_5,F5_6,F5_7,F5_8,F5_9,F5_10"

# Loop through each interval on the phoneme tier.
for thisInterval from 1 to numberOfIntervals
    
	# Get the label of the interval
    	select TextGrid 'thisTextGrid$'
    	thisPhoneme$ = Get label of interval: 1, thisInterval

	# Only process when the interval is labeled (skip empty intervals)
	if thisPhoneme$ <> ""

        	appendInfoLine: "Processing labeled interval ", thisInterval, ": ", thisPhoneme$
            
        	# Find the midpoint, time1, and 10-interval
        	thisPhonemeStartTime = Get start point: 1, thisInterval
        	thisPhonemeEndTime   = Get end point:   1, thisInterval
        	duration = thisPhonemeEndTime - thisPhonemeStartTime
        	time1 = thisPhonemeStartTime
        	interval = duration/10
            
        	# Extract formant measurements
		formant$ = ""
        	select Formant 'thisSound$'
        	for f from 1 to 5
            		formant = Get mean... f thisPhonemeStartTime thisPhonemeEndTime hertz
            		formant$ = formant$ + string$(formant) + ","
        	endfor
        	
		# Extract 10-point formants
		formant_10$ = ""
		for f from 1 to 5
			for timePoint from 1 to 10
				formant_10 = Get mean... f time1+(timePoint-1)*interval time1+timePoint*interval hertz
				formant_10$ = formant_10$ + string$(formant_10) + ","
        		endfor
		endfor

        	# Save to a spreadsheet
       		appendFileLine: "'outputPath$'", 
                        	...time1,",",
				...thisPhoneme$,",",
				...duration,",",
				...formant$,
				...formant_10$
    	endif

endfor

appendInfoLine: "Whoo-hoo! It didn't crash!"