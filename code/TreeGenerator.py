# -*- coding: utf-8 -*-

"""
TreeGenerator.py

This script takes a treefile from a BEAST run, containing the posterior distribution of trees after removal of burnin.
Steps:
    1. Read arguments using argParse
    2. From treeFile, connect number to header, if labels should be added later
    3. Extract N number of trees
    4. Create function for adding nodes to labels
    5. Create trees
    6. Print output

usage: python TreeGenerator.py --input_trees treefile.trees --n_trees 200

for help: python TreeGenerator.py --help or python TreeGenerator.py -h

Author: Lovisa Lindquist
Date: 2025-12-17
"""
# import packages
import re
import random
import argparse
import os
import sys

""" Step 1: Read arguments using argParse"""
    
# create argument parser
parser = argparse.ArgumentParser()
parser.add_argument('--input_trees', help='Sample of at least 100 BEAST trees from posterior distribution without burn-in.')
parser.add_argument('--n_trees', help='Number of trees to be randomly selected from sample. Must be >= 100.')
args = parser.parse_args()

# get directory for output files
pwd = os.getcwd()

# read input trees
input_trees = open(args.input_trees, "r")  
tree = input_trees.readlines()

""" Step 2: From treeFile, connect number to header, if labels should be added later """

# error handling for input file
id_dict = {} # make dictionary to hold ID-header combinations
keep_going = "YES" # while this is YES, proceed
for line in range(1, len(tree)): # iterate through tree
    if tree[line].startswith("\tTranslate"): # if the "translate" line is found, this is where we start searching
        i = 1 # this is needed to keep loop going forward
        while keep_going == "YES": # if we should keep searching
            if tree[line+i].startswith("\t\t;\n"): # if the end is found, break out
                keep_going == "NO" 
                break
            else: # while we have not reached the end, append the number as key and header as value
                id_dict[tree[line+i].split(" ")[0].strip("\t")] = tree[line+i].split(" ")[1].strip(",\n")
                i = i+1 # move on

""" Step 3: Extract N number of trees"""

# error handling of input number (must be above 100 and maximum number of trees in input file)
# read input as integer
selected_number = int(args.n_trees)
#selected_number = 100

# create function assessing if input is integer between 100 and number of trees, else terminate
def numberValidation(selected_number, tree):
    
    if type(selected_number) != int:
        print("Number of selected trees must be an integer. Terminating...")
        sys.exit()
    if selected_number < 100:
        print("Number of selected trees must be >= 100. Adjust the number of trees. Terminating...")
        sys.exit()
    if selected_number > len(tree):
        print("Number of selected trees higher than number of trees in posterior distribution. Adjust the number of trees. Terminating...")
        sys.exit()

numberValidation(selected_number, tree)

# identify row where trees start
first_row = 0
for i in range(0, len(tree)): #iterate through file
    if tree[i] == "\t\t;\n": # when taxon part ends, identify row number
        first_row = i

# if trees were never found, terminate
if first_row == 0:
    print("Trees not found. Terminating...")
    sys.exit()

# read input number of trees
random_n = sorted(random.sample(range(first_row+1,len(tree)-1), selected_number))

# select trees from posterior distribution
selected_trees = []
for index in random_n:
    selected_trees.append(tree[index])

# make sure the number of trees is correct (i.e. length of selected trees matches selected number)
def treeValidation(trees, number):
    
    number_trees = len(trees)
    
    if number_trees == number:
        pass
    else:
        print("Error: Number of trees not matching. Terminating...")
        sys.exit
    
treeValidation(selected_trees, selected_number)

""" Step 4: Create function for adding nodes to labels"""
# create function for adding labels
def addLabels(tree):
    
    # make a copy of the input tree
    tree1 = tree
    
    # while we should keep searching
    keep_going = "YES"
    while keep_going == "YES":
        
        # identify a single digit followed by a colon, this should be exchanegd for the corresponding label
        m = re.search("[\(,]{1}\d+:", tree1)
        
        # if found, append according to preceding character ("(" or ",")), exchange the number ofr the header in the dictionary
        if type(m) == re.Match:
            
            if "(" in tree1[m.start():m.end()]:
                hit = tree1[m.start():m.end()].strip("(:")
                name = id_dict.get(hit)
                tree1 = "(" + tree1[0:m.start()] + name + ":" + tree1[m.end():]
                
            elif "," in tree1[m.start():m.end()]:
                hit = tree1[m.start():m.end()].strip(":,")
                name = id_dict.get(hit)
                tree1 = tree1[0:m.start()] + "," + name + ":" + tree1[m.end():]
        
        # if an integer: was not found, break out    
        else:
            keep_going = "NO"
            break
        
    # append INTERNAL labels
    keep_going = "YES" #while we should keep searching
    count = 1 # start with INTERNAL node 1, then add 1 etc
    while keep_going == "YES":
        
        # when an internal node is found (characterised by colon immediately following a ")")
        m = re.search("\):", tree1)
        
        # if found, append INTERNALX, where X is the count above
        if type(m) == re.Match:
            hit = tree1[m.start():m.end()].strip("(:")
            name = "INTERNAL" + str(count)
            tree1 = tree1[0:m.start()] + ")" + name + ":" + tree1[m.end():]
            count = count+1 # add one to count 
        
        # when no more internal nodes found, break out
        else:
            keep_going = "NO"
            break
        
    # return the labelled tree
    return(tree1)

""" Step 5: Create trees"""
# create lists to hold trees when generated
Ntrees = list()
Strees = list()
Timetrees = list()

# iteratate through trees
for tree in selected_trees:
    
    # identify start of file and remove initial line
    start = re.search(" = ", tree)
    tree = tree[start.start()+8:]
    
    # create three new trees, start at the same point (i.e., original tree)
    N_tree = tree
    S_tree = tree
    Dist_tree = tree
    
    # iterate through the tree and exchange information
    i = 1 # start at 1, meaning "continue"
    while i < 10: # while the number is less than 10, continue
        
        # identify the first and last parts of the section with information
        start_side = re.search("\[", tree)
        end_side = re.search("\]\:\d+\.\d+[E-]*\d+", tree)

        # if such markers are identified, extract the portion between these two marks
        if type(start_side) == re.Match and type(end_side) == re.Match:
            stretch = tree[start_side.start():end_side.end()]
            
            # then within the tree, identify the first "S=x.x", "N=x.x" "rate=x.x", and distance after the end"
            S = tree[re.search("[,&]+S=\d+.\d+", tree).start()+3:re.search("[,&]+S=\d+.\d+", tree).end()]
            N = tree[re.search("[,&]+N=\d+.\d+", tree).start()+3:re.search("[,&]+N=\d+.\d+", tree).end()]
            Dist = stretch[re.search("\d\]:", stretch).end():re.search("\]\:\d+\.\d+[E-]*\d+", stretch).end()]
            Rate = stretch[re.search("rate=\d+\.\d+[E\-\d]*", stretch).start()+5:re.search("rate=\d+\.\d+[E\-\d]*", stretch).end()]
            
            # To get the overall value, multiply the branch length (Dist) with the rate (Rate).
            DistRate = str(float(Dist)*float(Rate)).replace("e", "E")
            # the N and S scores represent a proportion of the overall value, calculate the sum of N and S
            TotalNS = float(N) + float(S) 
            if TotalNS > 0: # if both N and S > 0
            # calculate proportion N (PN) and proportion S (PS)
                PN = float(N) / TotalNS 
                PS = float(S) / TotalNS
                # calculate the adjusted overall values by multiplying PN and PS with the DistRate
                AdjN = float(PN) * float(DistRate)
                AdjS = float(PS) * float(DistRate)
            # if both N and S are 0
            else: 
                AdjN = DistRate # the adjusted N should be effectively 0
                AdjS = DistRate # the adjusted S is the overall value
            
            # again, if a stretch was found, exchange this portion with the calculated information
            if len(stretch) > 1 :
                tree = tree.replace(stretch, ":" + Dist)
                N_tree = N_tree.replace(stretch, ":" + str(AdjN))
                S_tree = S_tree.replace(stretch, ":" + str(AdjS))
                Dist_tree = Dist_tree.replace(stretch, ":" + Dist)
                
                # if something was indeed added, keep i at 1 to continue searching
                i = 1
        # at the end, no new section will be identified, and the process is terminated
        else:
            i = 11
            break
    
    # call function of each tree to add labels to nodes
    #N_tree = addLabels(N_tree) 
    #S_tree = addLabels(S_tree) 
    #Dist_tree = addLabels(Dist_tree) 
    
    # append the final trees to each list
    Ntrees.append(N_tree)
    Strees.append(S_tree)
    Timetrees.append(Dist_tree)
    

""" Step 6: Print output"""
# open output files (EN_trees, ES_trees, Time_trees), overwriting allowed
N_output = open("{}/EN_trees.txt".format(pwd), "w")
S_output = open("{}/ES_trees.txt".format(pwd), "w")
Time_output = open("{}/Time_trees.txt".format(pwd), "w")

# all files are assumed to be the same length, so for each row in one of the files,
# print each row from each file to the corresponding output file
for i in range(0,len(Timetrees)):
    N_output.write(Ntrees[i])
    S_output.write(Strees[i])
    Time_output.write(Timetrees[i])


# close input and output files
N_output.close()
S_output.close()
Time_output.close()    
input_trees.close()    
    
    
    
    
    
    
    
    
    
    
    















