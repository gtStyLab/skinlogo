breed [staphs staph] ;; define the staphylococci breed
breed [corynes coryne] ;; define the corynebacteria breed
breed [acines acine] ;; define the acineonibacteria breed
breed [subtils subtil];; define the Bacillus subtilis breed
turtles-own [age energy remAttempts]
patches-own [glucose ser thr gly ala his pro leuiso val FA phetyr mal abx avaMetas]
globals [ negMeta testState result]


to display-labels
;; Shows levels of energy on the turtles in the viewer
  ask turtles [set label ""]
  ask corynes [set label round energy ]
  ask staphs [set label round energy ]
  ask acines [set label round energy ]
end


to setup
  ;; ensure the model starts from scratch
  clear-all
  ;; Initializing the turtles and patches

	;; populates the world with the bacteria population at the initial-numbers set by the user
  set-default-shape staphs "dot"
  create-staphs (initNumstaphs) [
    set color blue
    set size .25
    set energy 100
    set age random 100
    setxy random-xcor random-ycor
  ]
  set-default-shape corynes "dot"
  create-corynes (initNumcorynes ) [
    set color green
    set size 0.25
    set energy 100
	  set age random 100
    setxy random-xcor random-ycor
  ]
  set-default-shape acines "dot"
  create-acines (initNumacines ) [
    set color red
    set size .25
    set energy 100
	  set age random 100
    setxy random-xcor random-ycor
  ]
  set-default-shape subtils "dot"
  create-subtils (initNumsubtils ) [
    set color grey
    set size .25
    set energy 100
	  set age random 100
    setxy random-xcor random-ycor
  ]

	;; initializes the patch variables
  ;; nmol/cm2 * 10
  ask patches [
    set glucose 12
    set ser 3700
    set thr 840
    set gly 2500
    set ala 1840
    set his 1010
    set pro 420
    set leuiso 330
    set val 300
    set FA 1170
    set phetyr 295
    set mal 0
    set abx 0
  ]

  ;; Setup for stop if negative metas
  set negMeta false

  ;; set time to zero
  reset-ticks

  ;; reset the testState
  set testState 0

end


to go
;; This function determines the behavior at each time tick

  ;; stop if error or unexpected output
  stopCheck

  ;; Modify the energy level of each turtle and metabolite level of each patch
  ask patches [
    patchEat
;    storeMetabolites
  ]
  ;; make meta must be in seperate ask, sequential tasks
  ask patches[
    makeMetabolites
  ]
  ask patches [
    checkAbx
  ]
  ask patches [
    AbxAction
  ]
  ;; agents do their other procedures for this tick
  bactTickBehavior

  ;; Probiotics or bacteria in
  bactIn

  ;; Increment time
  tick

end


to stopCheck
;; code for stopping the simulation on unexpected output

  ;; Stop if negative number of metas calculated
  if negMeta [stop]

  ;; Stop if any population hits 0 or there are too many turtles
  if (count turtles > 1000000) [ stop ]
  if not any? turtles [ stop ] ;; stop if all turtles are dead
end

to bactIn
  ;; controls when probiotics enter system
  if ticks mod tickBacInflow = 0 and ticks != 0[
    inConc
  ]
end

to checkAbx
  if ticks mod tickAbxInflow = 0 and ticks != 0[
    set abx (abx + inConcAbx) ;ug/cm2
  ]
end
to AbxAction
  let sadBact (turtles-here)
  let iter 0
  while [(abx > 1 ) and any? sadBact and iter < 100][
    ask one-of sadBact[bactAbx]
    set sadBact (turtles-here)
    set iter (iter + 1)
  ]
end
to bactAbx
    (ifelse breed = staphs or breed = corynes or breed = acines [
     if abx > 10 [
      ask patch-here [
        set abx (abx - 10)
      ]
      die
    ]
  ]


  )
end
;; Each of these functions are currently equivalent, different function so we can expand on it if needed
to deathstaphs
;; staphylococci die if below the energy threshold or if excreted
  if energy <= 0[
    die
  ]

end

to deathacines
;; acinetobacter die if below the energy threshold or if excreted
  if energy <= 0 [
    die
  ]
end

to deathcorynes
;; corynebacteria die if below the energy threshold or if excreted
  if energy <= 0 [
    die
  ]
end

to deathsubtils
;; subtilis die if below energy threshold or if excreted
  if energy <= 0 [
    die
  ]
end

to makeMetabolites
;; Runs through all the metabolites and makes them


  if ((ala < 0) or (ser < 0) or (thr < 0) or (gly < 0) or (glucose < 0) or (his < 0) or (pro < 0)
    or (leuiso < 0) or (val < 0) or (FA < 0) or (phetyr < 0) or (mal < 0)) [
    print "ERROR! Patch reported negative metabolite. Problem with simulation leading to inaccurate results. Terminating Program."
    set negMeta true
    stop
  ]


;; nmol/cm2/min * 10
  	  set glucose (glucose + .01)
      set ser (ser + 4.5)
  		set thr (thr + 1)
      set gly (gly + 3.4)	
			set ala (ala + 2.1)
      set his (his + 1)
      set pro (pro + .5)
      set leuiso (leuiso + .31)
      set val (val + .33)
      set FA (FA + 4.5)
      set phetyr (phetyr + .31)
  if ticks mod tickBacinflow = 0 and ticks != 0[
    set mal (mal + inConcMal)]

  if ((glucose < 0.001)) [set glucose 0]
  if ((ser < 0.001)) [set ser 0]
	if ((thr < 0.001)) [set thr 0]
  if ((gly < 0.001)) [set gly 0]
	if ((ala < 0.001)) [set ala 0]
  if ((his < 0.001)) [ set his 0]
  if ((pro < 0.001)) [ set pro 0]
  if ((leuiso < 0.001)) [set leuiso 0]
  if ((val < 0.001)) [ set val 0]
  if ((FA < 0.001)) [ set FA 0]
  if ((phetyr < 0.001)) [set phetyr 0]
  if ((mal < 0.001)) [set mal 0]


end


to bactTickBehavior
;; reproduce the chosen turtle
  ask staphs [
    deathstaphs ;; check that the energy of the bacteria is enough, otherwise bacteria dies
    if (age mod staphDoub = 0 and age != 0)[ ;;this line controls on what tick mod reproduce
      reproduceBact ;; run the reproduce code for bacteria
    ]
  	set age (age + 1) ;; increase the age of the bacteria with each tick
  ]

  ask corynes [;;controls the behavior for the corynes bacteria
    deathcorynes
    if (age mod coryneDoub = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

  ask acines [;;controls the behavior for the acines
    deathacines
    if (age mod acineDoub = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

  ask subtils [;;controls the behavior for the subtils
    deathsubtils
    if (age mod subtilDoub = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

end


to reproduceBact
;; reproduce the chosen turtle
  if energy > 50 [ ;;turtles-here check to model space limit and count turtles-here < 1500
    let tmp (energy / 2 )
    set energy (tmp) ;; parent's energy is halved
    hatch 1 [
      rt random-float 360
      set energy tmp ;; child gets half of parent's energy
	    set age 0
    ]
  ]
end


to inConc
;; controls the amount of each type of bacteria entering the simulation


  create-staphs inConcStaphs [
    set color blue
    set size 0.25
    set energy 100
    set age random 100
    setxy random-xcor  random-ycor
  ]

  create-corynes inConcCorynes [
    set color green
    set size 0.25
    set energy 100
    set age random 100
    setxy random-xcor  random-ycor
  ]

  create-acines inConcacines [
    set color red
    set size .25
    set energy 100
    set age random 100
    setxy random-xcor  random-ycor
  ]
  create-subtils inConcSubtils [
    set color grey
    set size .25
    set energy 100
    set age random 100
    setxy random-xcor  random-ycor
  ]

end

to bactEat [metaNum]
;; run this through a turtle with a metaNum parameter to have them try to eat the nutrient

  if (metaNum = 10)[;;glucose 32 ATP
    ifelse (breed = corynes or breed = staphs or breed = subtils )[;; check correct breed
      set energy (energy + 3.2);; increase the energy of the bacteria
      ask patch-here [
          set glucose (glucose - 1);; reduce the meta count
        if (glucose < 1)[;; remove the meta from avaMetas if there is no more of it
          set avaMetas remove 10 avaMetas
        ]
      ]
    ]
      [; else do nothing
      ]

  ]

  if (metaNum = 11)[;;ser
    (ifelse (breed = corynes or breed = staphs)[
      set energy (energy + 1.25)
      ask patch-here [
        set ser (ser - 1)
        if (ser < 1)[
          set avaMetas remove 11 avaMetas
        ]
      ]
    ]
      [; else do nothing
      ])

    ];;end else

  if (metaNum = 12)[;;thr
    ifelse (breed = staphs ) [
        set energy (energy + 1.9) ;; 35
        ask patch-here [
        	set thr (thr - 1)
          if (thr < 1)[
            set avaMetas remove 12 avaMetas
          ]
        ]
      ]
      [
      ]
    ]

  if (metaNum = 13)[;;gly
    ifelse (breed = staphs ) [
        set energy (energy + 1.25) ;; 35
        ask patch-here [
        	set gly (gly - 1)
          if (gly < 1)[
            set avaMetas remove 13 avaMetas
          ]
        ]
      ]
      [
      ]
    ]

  if (metaNum = 14)[;;ala
    (ifelse ( breed = acines or breed = subtils or breed = corynes or breed = staphs)[
      set energy (energy + 1.25)
      ask patch-here [
        set ala (ala - 1)
        if (ala < 1)[
          set avaMetas remove 14 avaMetas
        ]
      ]
    ]
      [
      ])
  ]

  if (metaNum = 15)[;;his
    ifelse (breed = acines or breed = staphs or breed = corynes or breed = subtils)[
        set energy (energy + 2.25)
        ask patch-here [
        set his (his - 1)
        if (his < 1)[
          set avaMetas remove 15 avaMetas
        ]
      ]
    ]
      [
      ]
  ]

  if (metaNum = 16)[;;pro
    ifelse (breed = staphs or breed = corynes or breed = subtils or breed = acines)[
      set energy (energy + 2.75)
      ask patch-here [
        set pro (pro - 1)
        if (pro < 1)[
          set avaMetas remove 16 avaMetas
        ]
      ]
    ]

      [
      ]
  ]



  if (metaNum = 17)[;;leuiso
    ifelse (breed = staphs )[
      set energy (energy + 3.3)
      ask patch-here [
        set leuiso (leuiso - 1)
        if (leuiso < 1)[
          set avaMetas remove 17 avaMetas
        ]
      ]
    ]

    [
    ]
  ]
  if (metaNum = 18)[;;val
    ifelse (breed = staphs )[
      set energy (energy + 2.75)
      ask patch-here [
        set val (val - 1)
        if (val < 1)[
          set avaMetas remove 18 avaMetas
        ]
      ]
    ]

    [
    ]
  ]

  if (metaNum = 19)[;;FA
    ifelse (breed = (corynes) )[
      set energy (energy + 10.6)
      ask patch-here [
        set FA (FA - 1)
        if (FA < 1)[
          set avaMetas remove 19 avaMetas
        ]
      ]
    ]
    [;;else
      ;;do nothing
    ]

  ]


  if (metaNum = 20) [;;phetyr
    ifelse (breed = acines)[
      set energy (energy + 3)
      ask patch-here [
        set phetyr (phetyr - 1)
        if (phetyr < 1)[
          set avaMetas remove 20 avaMetas
        ]
      ]
    ]
    [
    ]
  ]

  if (metaNum = 21) [;;mal
    ifelse (breed = subtils)[
      set energy (energy + 1)
      ask patch-here [
        set mal (mal - 1)
        if (mal < 1)[
          set avaMetas remove 21 avaMetas
        ]
      ]
    ]
    [
    ]
  ]


end

to patchEat
;; run this on a ask patches to have them start the turtle eating process
  ask turtles-here [
    set remAttempts 2 ;; reset the number of attempts
    set energy (energy - (100 / 1440)) ;; decrease the energy of the bacteria, currently survive 1 day no eat
  ]
  let allMetas (list glucose ser thr gly ala his pro leuiso val FA phetyr mal);; list containing numbers of all the metas
  set avaMetas []

  ;; initialize the two lists
  let hungryBact (turtles-here with [(energy < 80) and (remAttempts > 0)])
  let i 0
  while [i < (length(allMetas))][
    if (item i allMetas >= 1) [
      set avaMetas lput (i + 10) avaMetas
    ]
    set i (i + 1)
  ]
  let iter 0 ;; used to limit the number of times the next while loop will occur, aribitrary
  ;; do the eating till no metas or not hungry
  while [(length(avaMetas) > 0) and any? hungryBact and iter < 100] [
    ;; code here to randomly select a turtle from hungryBact and then ask it to run bactEat with a random meta from ava. list
    ask one-of hungryBact [
      bactEat(one-of avaMetas)
      set remAttempts remAttempts - 1
    ]
    ;;re-bound agent set
    set hungryBact (turtles-here with [(energy < 80) and (remAttempts > 0)])

    set iter (iter + 1)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
-535
49
2074
109
-1
-1
51.0
1
10
1
1
1
0
0
1
1
0
50
0
0
1
1
1
ticks
30.0

BUTTON
18
10
82
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
96
10
159
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
802
118
1205
434
Populations
Time
Populations
0.0
10.0
0.0
10.0
true
true
"ifelse plots-on? [\nauto-plot-on\n]\n[auto-plot-off]" ""
PENS
"Acines" 1.0 0 -2674135 true "" "plot count acines"
"staphs" 1.0 0 -13345367 true "" "plot count staphs"
"Corynes" 1.0 0 -10899396 true "" "plot count corynes"
"Subtils" 1.0 0 -7500403 true "" "plot count subtils"

MONITOR
93
424
185
469
acinetobacter
count acines
17
1
11

MONITOR
185
424
250
469
staph
count staphs
17
1
11

MONITOR
250
424
346
469
corynebacteria
count corynes
17
1
11

MONITOR
5
468
104
513
Percentage acines
100 * count acines / count turtles
2
1
11

MONITOR
104
469
206
514
Percentage staph
100 * count staphs / count turtles
2
1
11

MONITOR
205
468
313
513
Percentage corynes
100 * count corynes / count turtles
2
1
11

MONITOR
5
424
94
469
Total Bacteria
count turtles
3
1
11

MONITOR
428
424
485
469
Glucose
sum [glucose] of patches
2
1
11

MONITOR
485
424
542
469
serine
sum [ser] of patches
2
1
11

MONITOR
665
424
722
469
alanine
sum [ala] of patches
2
1
11

MONITOR
715
469
772
514
malate
sum [mal] of patches
2
1
11

MONITOR
542
424
608
469
thr
sum [thr] of patches
2
1
11

MONITOR
346
424
415
469
subtilis
count subtils
17
1
11

MONITOR
312
468
414
513
Percentage subtilis
100 * count subtils / count turtles
2
1
11

SWITCH
1221
398
1327
431
plots-on?
plots-on?
0
1
-1000

INPUTBOX
488
330
614
390
inConcSubtils
50000.0
1
0
Number

INPUTBOX
488
152
614
212
inConcStaphs
0.0
1
0
Number

INPUTBOX
488
271
614
331
inConcAcines
0.0
1
0
Number

INPUTBOX
488
211
614
271
inConcCorynes
0.0
1
0
Number

INPUTBOX
613
152
739
212
tickBacInflow
3000.0
1
0
Number

INPUTBOX
160
152
315
212
initNumStaphs
3000.0
1
0
Number

INPUTBOX
160
332
315
392
initNumSubtils
0.0
1
0
Number

INPUTBOX
160
272
315
332
initNumAcines
3000.0
1
0
Number

INPUTBOX
160
212
315
272
initNumCorynes
3000.0
1
0
Number

TEXTBOX
492
127
639
157
Add Bacteria
18
0.0
1

TEXTBOX
320
126
513
157
Metabolite Variables
18
0.0
1

TEXTBOX
174
126
315
155
Initial Bacteria
18
0.0
1

TEXTBOX
8
123
148
149
Bacteria growth
18
0.0
1

INPUTBOX
5
152
160
212
staphDoub
50.0
1
0
Number

INPUTBOX
5
212
160
272
coryneDoub
90.0
1
0
Number

INPUTBOX
5
271
160
331
acineDoub
40.0
1
0
Number

INPUTBOX
5
331
160
391
subtilDoub
24.0
1
0
Number

TEXTBOX
14
403
164
421
Bacteria Stats
14
0.0
1

TEXTBOX
429
401
579
419
Metabolite Stats
14
0.0
1

MONITOR
721
424
779
469
histidine
sum [his] of patches
2
1
11

MONITOR
429
469
486
514
proline
sum [pro] of patches
2
1
11

MONITOR
486
469
543
514
leu/iso
sum [leuiso] of patches
2
1
11

MONITOR
602
469
659
514
FA
sum [FA] of patches
2
1
11

MONITOR
658
469
715
514
phe/tyr
sum [phetyr] of patches
2
1
11

INPUTBOX
315
152
470
212
inConcAbx
0.0
1
0
Number

MONITOR
772
469
829
514
abx
sum [abx] of patches
17
1
11

INPUTBOX
315
211
470
271
tickAbxInflow
30000.0
1
0
Number

INPUTBOX
317
271
390
331
inConcMal
0.0
1
0
Number

MONITOR
607
424
664
469
gly
sum [gly] of patches
2
1
11

MONITOR
544
469
601
514
val
sum [val] of patches
2
1
11

@#$#@#$#@
#SkinLogo Documentation
This document contains information on how to use the model and how it functions. One can search for specific information about a component by using the find tool from the edit option tab.

#Copyright and other information

This model is built off of code obtained from GutLogo. The original publication describing GutLogo can be found here: 

Lin C, Culver J, Weston B, Underhill E, Gorky J, Dhurjati P (2018) GutLogo: Agent-based modeling framework to investigate spatial and temporal dynamics in the gut microbiome. PLoS ONE 13(11): e0207072. https://doi.org/10.1371/journal.pone.0207072

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Model summary
This model is a framework for the simulation of bacteria populations on human skin.

# How to use the interface
SkinLogo uses the NetLogo interface. The model comes with default values that match our control simulations. A user can begin the simulation by clicking the setup and then the go buttons. The long bar underneath the buttons will visualize the current populations of bacteria. The plot on the right will display the populations of the bacterial species on the skin. When testing conditions, be sure to allow the simulation to reach an equilibrium-like state before inducing a perturbation. 

The left block of inputs control the doubling times of the bacterial species. Feedback loops have not yet been implemented. Therefore, widely different doubling times will lead to an unstable simulation. The inital bacteria column of inputs control the colonies that initially populate the skin. The 'initNum' variables control the initial values for each respective species. 

The next section of inputs are variables dealing with the addition of metabolites or bacteria. The 'inConc' inputs determine the amount of each species of bacteria that will enter the simulation. The 'tickInflow' variable controls how often bacteria enter the simulation. 

One can use the Behaviorspace module to schedule multiple simulations in parallel by clicking the tools option and selecting Behaviorspace. Several of the experiments done in this paper are available for editing in the interface. 

# Variables


##turtle breeds

**staphs**:  The staphylococci breed of turtles, agentset that contains all of the staphylococci turtle types.

**corynes**: The corynebacteria breed of turtles, agentset that contains all of the corynebacteria

**acines**:  The acinetobacter breed of turtles, agentset that contains all of the acinetobacter

**subtils**: The B. subtilis breed of turtles, agentset that contains all of the B. subtilis


##turtles-own

**age**: Positive integer value representing the number of ticks the bacteria has been alive for. Used to determine if a bacteria would reproduce on the current tick. Seed colony bacteria are given a random age from 0 to 1000.

**doubConst**: A floating point value that can be used to modify the doubling time of a bacteria. This value is multiplied by the bacterial doubling times inputted to get the tick mod on which bacteria can reproduce.

**energy**: Floating point number used to represent the health of a bacteria. The energy of a bacteria is reduced by a set amount each tick and increased when the bacteria consumes food. During reproduction, half of the energy of a parent bacteria is transferred to the child .


**remAttempts**: Positive integer value used to keep track of the number of attempts provided to the bacteria to consume some food source. Limits the maximum number of attempts a bacteria can make each tick.



##patches-own

**avaMetas**: Mutating list of the integers 10 through 21. Each int represents a food source that is available in the current patch. When every metabolite is available, the list will be [10 11 12 13 14 15 16 17 18 19 20 21]. If no metabolite is available, the list will be empty. This is used in the eating code so only food sources that are available will be presented to bacteria.

           

**glucose**: Floating point value that represents the number of glucose units that are available for the bacteria to consume


**ser**: Floating point value that represents the number of serine units that are available for the bacteria to consume


**thr**: Floating point value that represents the number of threonine units that are available for the bacteria to consume


**gly**: Floating point value that represents the number of glycine units that are available for the bacteria to consume


**ala**: Floating point value that represents the number of alanine units that are available for the bacteria to consume


**his**: Floating point value that represents the number of histidine units that are available for the bacteria to consume


**pro**: Floating point value that represents the number of proline units that are available for the bacteria to consume


**leuiso**: Floating point value that represents the number of leucine and isoleucine units that are available for the bacteria to consume


**val**: Floating point value that represents the number of valine units that are available for the bacteria to consume


**FA**: Floating point value that represents the number of fatty acid units that are available for the bacteria to consume


**phetyr**: Floating point value that represents the number of phenylalanine and tyrosine units that are available for the bacteria to consume


**mal**: Floating point value that represents the number of malate units that are available for the bacteria to consume


##globals

**negMeta**: Boolean value set to true if a patch ever has a negative number of a metabolite. Used to terminate program w/o an error popup.


**testState**: Postive integer value that tracks which state the experiment is in. Used exclusively in the automatic experiment testing.

**result**: For running the JUnit tests.


##Function Documentation:


**setup**:
Function Type: 	Procedure
Input:			None
Output:		None
Purpose:		Initializes the simulation based on the global variables’ values.
Description:		Populates the world with bacteria placed randomly and initializes all variables not given by user. Resets the tick counter. Resets the simulation completely when run.

**go**:
Function Type:	Procedure
Input:			None
Output:		None
Purpose:		Runs the simulation
Description:		This function is executed at the start of each tick. Calls all of the relevant functions in order and then increments the tick counter.

**stopCheck**:
Function Type:	Procedure
Input:			None
Output:		None, can print error messages
Purpose:		Determine if simulation needs to terminate and terminates it
Description:		This function can be used to stop the simulation automatically and needs to be called in the go function.


**bactIn**:
Function Type:	Procedure
Input:			None
Output:		None
Purpose:		Controls when bacteria enter the system.
Description:		Has an if statement that takes the mod of the tick count wrapped around a call to inConc. Defaults to allowing inConc to be called every tick.

**death-staphs**:
Function Type:	Procedure
Input:			Must be called on an agent, e.g. via ‘ask staphs’
Output:		None
Purpose:		Removes dead staphylococci from model
Description:		Called as part of bacteria behavior. Will have bacteria die if energy is less than or equal to 0 or if excreted.

**death-corynes**:
Function Type:	Procedure
Input:			Must be called on an agent, e.g. via ‘ask corynes’
Output:		None
Purpose:		Removes dead corynebacteria from model
Description:		Called as part of bacteria behavior. Will have bacteria die if energy is less than or equal to 0 or if excreted.

**death-acines**:
Function Type:	Procedure
Input:			Must be called on an agent, e.g. via ‘ask acines’
Output:		None
Purpose:		Removes dead acinetobacter from model
Description:		Called as part of bacteria behavior. Will have bacteria die if energy is less than or equal to 0 or if excreted.

**death-subtils**:
Function Type:	Procedure
Input:			Must be called on an agent, e.g. via ‘ask subtils’
Output:		None
Purpose:		Removes dead B. subtilis from model
Description:		Called as part of bacteria behavior. Will have bacteria die if energy is less than or equal to 0 or if excreted.

**make-metabolites**:
Function Type:	Procedure
Input:			Must be called on a patch, e.g. via ‘ask patches’
Output:		None
Purpose:		Increases metabolites in the model
Description:		Increases amount of metabolites based on values extracted from literature of human forearm skin


**bacteria-tick-behavior**:
Function Type:	Procedure
Input:			None
Output:		None
Purpose:		Controls the behavior of each bacterial species.
Description:		Call the reproduce and death functions each tick. Then runs the reproduction code when the age of the bacteria matches a multiple of the doubling time. Finally increases the age of the bacteria.

**reproduceBact**:
Function Type:	Procedure
Input:			Must be called on an agent, e.g. via ‘ask turtles’
Output:		None
Purpose:		If the bacteria called on is of age, reproduce
Description:		Creates a new bacteria from the parent bacteria with half of the the parent’s energy. The parent’s energy will be halved and its energy must be greater than a half to reproduce. The new bacteria age will be 0.


**inConc**:
Function Type:	Procedure
Input:			None
Output:		None
Purpose:		Control the amount of bacteria flowing into the simulation
Description:		This can be used to simulate probiotics. Creates bacteria on a  random x-coord and a random y-coord. The bacteria have a random age between 0 and 1000.

**bactEat**:
Function Type:	Procedure
Input:			metaNum, Must be called on an agent, e.g. via ‘ask turtles’
Output:		None
Purpose:		Feed the bacteria agents
Description:		This code is run through an agent and passed a metabolite number from avaMeta. If the species of the bacteria can process the metabolite, then the energy of the bacteria is increased. Then the metabolite counts in that patch is decreased and if the metabolite count would be reduced below 1, the metabolite is removed from avaMetas. Called through patchEat.

**patchEat**:
Function Type:	Procedure
Input:			must be called on a patch, e.g. via ‘ask patches’
Output:		None
Purpose:		Controls the bacteria eating process on the current patch.
Description:		Initializes the remAttempts for all of the bacteria on the patch and then decreases the energy of the bacteria. Then initializes the allMetas, avaMetas, and hungryBact lists. While there are avaMetas and there are any hungryBact chooses one of the avaMetas and then a hungryBact and runs the bactEat code on that bacteria and then decreases its remAttempts. At the end of the while, the hungryBact list is reinitialized to remove bacteria that have eaten or have no more attempts. This loops until there are no more hungryBact or metabolites.

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bacteria
true
0
Circle -7500403 true true 103 28 95
Circle -7500403 true true 105 45 90
Circle -7500403 true true 105 60 90
Circle -7500403 true true 105 75 90
Circle -7500403 true true 105 90 90
Circle -7500403 true true 105 105 90
Circle -7500403 true true 105 120 90
Circle -7500403 true true 105 135 90
Circle -7500403 true true 105 150 90
Circle -7500403 true true 105 165 90
Circle -7500403 true true 105 180 90

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="checkStable" repetitions="4" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100[
  go
]</go>
    <timeLimit steps="50"/>
    <metric>testConst</metric>
    <metric>flowDist</metric>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="27"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="flowTest" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
flowRateTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.333"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flowDist">
      <value value="0.278"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="glucTest" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
glucTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inFlowGlucose">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bifidosTest" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
bifidosTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcBifidos">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="flowTestB" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
flowRateTest</go>
    <timeLimit steps="303"/>
    <metric>testConst</metric>
    <metric>flowDist</metric>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.333"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flowDist">
      <value value="0.278"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="glucTestB" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
glucTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inFlowGlucose">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bifidosTestB" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
bifidosTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcBifidos">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="controlHealthy" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="controlAutistic" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count subtils</metric>
    <metric>count acines</metric>
    <enumeratedValueSet variable="subtilDoub">
      <value value="100"/>
      <value value="110"/>
      <value value="120"/>
      <value value="130"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="DisadvTest" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="59999"/>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count subtils</metric>
    <metric>count acines</metric>
    <enumeratedValueSet variable="subtilDoub">
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="repeatability" repetitions="4" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="59999"/>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count subtils</metric>
    <metric>count acines</metric>
  </experiment>
  <experiment name="malate dose response" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7900"/>
    <metric>count acines</metric>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count subtils</metric>
    <enumeratedValueSet variable="inConcTox">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcStaphs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcCorynes">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumAcines">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subtilDoub">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAbx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcApply">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumCorynes">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcSubtils">
      <value value="70000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coryneDoub">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickAbxInflow">
      <value value="50000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staphDoub">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAcines">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickBacInflow">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots-on?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumSubtils">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumStaphs">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acineDoub">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acetate-production">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcMal">
      <value value="0"/>
      <value value="5000"/>
      <value value="500000"/>
      <value value="50000000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="230112 malate test" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="8999"/>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count acines</metric>
    <metric>count subtils</metric>
    <enumeratedValueSet variable="inConcTox">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcCorynes">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcStaphs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumAcines">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subtilDoub">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAbx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcApply">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumCorynes">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickAbxInflow">
      <value value="50000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coryneDoub">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcSubtils">
      <value value="50000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staphDoub">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots-on?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickBacInflow">
      <value value="4500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAcines">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumSubtils">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumStaphs">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acineDoub">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcMal">
      <value value="370000000"/>
      <value value="37000000000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Antibiotic test" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="8999"/>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count acines</metric>
    <metric>count subtils</metric>
    <enumeratedValueSet variable="inConcTox">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcStaphs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcCorynes">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumAcines">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subtilDoub">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAbx">
      <value value="8000"/>
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcApply">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumCorynes">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickAbxInflow">
      <value value="4500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coryneDoub">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcSubtils">
      <value value="50000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staphDoub">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots-on?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAcines">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickBacInflow">
      <value value="4500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumSubtils">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumStaphs">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acineDoub">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcMal">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Base conditions" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="9000"/>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count acines</metric>
    <metric>count subtils</metric>
    <enumeratedValueSet variable="inConcTox">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcStaphs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcCorynes">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumAcines">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subtilDoub">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAbx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcApply">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumCorynes">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickAbxInflow">
      <value value="30000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coryneDoub">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcSubtils">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staphDoub">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots-on?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAcines">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickBacInflow">
      <value value="30000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumSubtils">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumStaphs">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acineDoub">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcMal">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Individual plots" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="9000"/>
    <metric>count staphs</metric>
    <metric>count corynes</metric>
    <metric>count acines</metric>
    <metric>count subtils</metric>
    <enumeratedValueSet variable="inConcTox">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcStaphs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcCorynes">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumAcines">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="subtilDoub">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAbx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcApply">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumCorynes">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickAbxInflow">
      <value value="30000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coryneDoub">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcSubtils">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staphDoub">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plots-on?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcAcines">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tickBacInflow">
      <value value="30000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumSubtils">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumStaphs">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acineDoub">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcMal">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
