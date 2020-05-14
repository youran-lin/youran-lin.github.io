# This script is written by Youran Lin (youran1@ualberta.ca) on April 5th, 2020
# It will provide 10-point normalized f0 contour and the duration
# Store the sound files and the TextGrid files (same name) under the same directory 
# Change the directory at the top and bottom from "C:\Users\19930\Desktop\" to your directory
# The directory always ends with a "\" Don't store other sound files or TextGrids in this folder 
# TextGrid tier name should be "1" or you can change accordingly in the script, don't use point tiers
# Label the tone number, it'll show up in the output table

# Create a table with the name 'outFile$' with 1 row and desired column names 
Create Table with column names... f0List 0 file tone duration(ms) f0_1 f0_2 f0_3 f0_4 f0_5 f0_6 f0_7 f0_8 f0_9 f0_10
Create Strings as file list... fileList *.wav
fileNumber = Get number of strings

for rowNum to fileNumber

	# Associate TextGrid file with the sound file
	select Strings fileList
	soundFileName$ = Get string... rowNum
	fileName$ = soundFileName$ - ".wav"
	tgFileName$ = fileName$ + ".TextGrid"
	Read from file: "'soundFileName$'"
	Read from file: "'tgFileName$'"

	# Get time from the TextGrid
	select TextGrid 'fileName$'
	tone$ = Get label of interval... 1 2
	begin_from = Get start time of interval... 1 2
	end_by = Get end time of interval... 1 2
	interval = (end_by - begin_from)/10
	duration_ms = (end_by - begin_from)*1000
	time1 = begin_from

	# Write the info of filename, tone number, and duration
	select Table f0List
	Append row
	Set string value... 'rowNum' file 'fileName$'
	Set string value... 'rowNum' tone 'tone$'
	Set string value... 'rowNum' duration(ms) 'duration_ms'
	
	# Write the 10 points of f0 to the table
	select Sound 'fileName$'
	Edit
	select Table f0List
	for f0Point to 10
		editor Sound 'fileName$'
  		time2 = time1 + interval
  		Select... time1 time2
  		f0 = Get pitch
		endeditor
		col$ = "f0_" + string$(f0Point)
		Set string value... 'rowNum' 'col$' 'f0'
  		time1 = time2
	endfor
	
	# Remove the sound file and TextGrid
	select Sound 'fileName$'
	plus TextGrid 'fileName$'
	Remove

endfor

# Output the table info
select Table f0List
Write to table file... f0List.txt


#####################################################
#    *       *         *     *                      #
#    *       *         *     *                      #
#   *       *         *     *                       #
#   *   *****   ***   *     *     ***               #
#  *****   *   *   * *     *     *   *              #
#  *       *  *****  *     *    *    *   **         #
# *       *   *     *   * *   * *   *    **         #
# *       *    ***   ***   ***   ***   **           #
#                                                   #
#                                                   #
#   ***        *                   *         *      #
#  *  *    *   *                   *         *      #
# *  *    *    *                  *         *       #
#    *   **    *  ***   **  ***   *     *** *       #
#   *    **   *  *   * *  *    * *     *   *        #
#   *   * *   * *    *   *       *    *    *        #
#    *  * *  *  *   *   *       *   * *   *  *   ** #
#     **   **    ***    *        ***   *** **    ** #
#####################################################
# Youran Lin, B.A., M.A., MScSLP/PhD Student        #
# Email: youran1@ualberta.ca                        #
# Website: https://youran-lin.github.io/            #
#####################################################