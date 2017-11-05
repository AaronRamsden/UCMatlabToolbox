# UCMatlabToolbox

_A Matlab Unit Commitment Toolbox for Future Grid Modeling for Educational and Research Purposes_

Aaron Ramsden & Gregor Verbi&#269;

School of Electrical & Information Engineering, Faculty of Engineering and Information Technologies, University of Sydney, New South Wales, Australia


## License

This work is intended for educational and research purposes only. The work is published under the [GNU General Public License v3.0](LICENSE.md).

## Attribution

### Australian Energy Market Operator (AEMO)

The contents of the folder `input_traces/` were sourced from the AEMO. These files are publically available on the [AEMO website](https://www.aemo.com.au). These traces and other useful data can be found by looking on the AEMO website under _Electricity_ &rarr; _Planning and Forecasting_ &rarr; _National Transmission Network Development Plan (NTNDP)_, and then looking around for databases or supporting material.

### M. Gibbard and D. Vowles

The 58-bus network model that is used in some of the case studies that are provided with the _UC Matlab Toolbox_ is based on the network model published in _Simplified 14-generator model of the SE Australian power system (Revision 3, June 2010)_ by M. Gibbard and D. Vowles.

### J. Glover, M. Sarma, and T. Overbye

The simple network model that is used in some of the case studies that are provided with the _UC Matlab Toolbox_ is based on a network model published in _Power System Analysis and Design, 5th ed. Cengage Learning, 2012_ by J. Glover, M. Sarma, and T. Overbye (Chapter 12, Example 12.8).


### Kristjan Jonasson

The contents of the folder `lib/rgb/` is credited to Kristjan Jonasson and is redistributed under [license](lib/rgb/license.txt) Copyright (c) 2009. This function was sourced from the [MathWorks File Exchange](https://au.mathworks.com/matlabcentral/fileexchange/24497-rgb-triple-of-color-name--version-2).

### A. Novianto, T. Stewart, and T. Perrau

Andreas Novianto, Thomas Stewart, and Thomas Perrau contributed to acquiring and processing the generator and demand data used in some of the case studies that are provided with the _UC Matlab Toolbox_.

## Installation

### Matlab Files

All of the required Matlab files are available [here](https://github.com/AaronRamsden/UCMatlabToolbox) on GitHub. The easiest way to install the files is:
* Click on _Clone or download_ &rarr; _Download ZIP_
* Copy the downloaded folder and all contents into the local _MATLAB_ directory
* Within Matlab, go to _Home_ &rarr; _Set Path_ &rarr; _Add with Subfolders..._, and select the downloaded folder
* Install Cplex as per the instructions below
* Type `UCGUI` in the command window to run the _Unit Commitment Matlab Toolbox_

Alternatively, clone the repository.

### Back-end Solver

A Mixed Integer Linear Programming (MILP) back-end solver is required for the UC Matlab Toolbox.

#### Cplex

The IBM ILOG CPLEX Optimization Studio is recommended to be used as a back-end MILP solver. Cplex is available to academics and students for free as part of the _IBM academic initiative program_, more information is available on the IBM [website](https://www.ibm.com/developerworks/community/blogs/jfp/entry/CPLEX_Is_Free_For_Students?lang=en).

Follow the installation instructions provided with the download. A useful tip for Mac users is to change the permission of the installation file to be executable before running it:
* In the terminal type "chmod +x file.bin" (e.g. "chmod +x cplex_studio123.acad.macos.bin")
* To run the .bin file (and start the installation process), type "./file.bin" (e.g. "./cplex_studio123.acad.macos.bin")

Detailed installation instructions that may be useful have been publised by [Columbia University](http://www.columbia.edu/~jz2313/INSTALL).

#### Matlab In-Built Optimisation Toolbox

The Matlab Optimisation Toolbox can be used as an alternative to Cplex. The benefit of this would be that the Matlab Optimisation Toolbox is included in most Matlab installs. The drawback is that the computational time required to perform simulations will significantly increase compared to using Cplex. This may not be an issue for simple models (on the order of 10 busses).

In order to use the Matlab Optimisation Toolbox, the Matlab function [UCGUI_cplex_solver.m](UC_simulation/UCGUI_cplex_solver.m) will have to be modified to use the Matlab function _intlinprog_.

More information on the Matlab Optimisation Toolbox can be found on the MathWorks [website](http://au.mathworks.com/help/optim/index.html), or by typing `help intlinprog` in the Matlab command window.

## Contribition

Open a pull request if you would like to contribute to this Matlab toolbox.
