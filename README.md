KymoRod
=========

Graphical User Interface for studying the growth of plant hypocotyl and root. 

The software allows to select a collection of images following the growth of a plant organ. 
Several processing steps can be applied to segment hypocotyls on images, extract the contour,
compute the Voronoi skeleton, measure curvilinear abscissa, identifies homologous positions on 
skeleton pairs, compute relative elongation rate, and finally display the result as a kymograph.

The software is developed for the Matlab platform.

## Installation

### Using the App

Recent versions of Matlab provide a mechanism for easily install application. To install the KymoRod application, simply follow these steps:
* Download [the latest version of the app](https://github.com/ijpb/KymoRod/releases) (as a `KymoRod-x.y.mlapp` file)
* Start Matlab
* Click on the "Install App" icon, in the "Apps" tab of the ribbon interface
* Select the "KymoRod.mlapp" file, click "OK",
* You're done!

### Manual installation

The program may alternatively be installed manually. This can avoid some dependencies of the Matlab installer. The procedure is as follows:

1. Download [the latest KymoRod archive](https://github.com/ijpb/KymoRod/releases) (as a `KymoRod-x.y.zip` file)
2. Unzip in the folder of your choice
3. Start matlab
4. Change current directory to locate in the extracted directory
5. Add the different paths, by typing `setupKymoRod`
6. Launch the graphical user interface by typing `startKymoRod`

## Software organisation

The software code is divided into three parts
* the **core** sub-directory contains all the computational part of the program
* the **userInterface** sub-directory contains code for GUI and dialogs
* the **lib** sub-directory contains additional required libraries

## References

The software was originally developed for the following study:
* **Renaud Bastien, David Legland, Marjolaine Martin, Lucien Fregosi, Alexis Peaucelle, Stéphane Douady, Bruno Moulia, Herman Höfte, 2016**. KymoRod: a method for automated kinematic analysis of rod-shaped plant organs. *The Plant Journal* 88(3), p. 468-475. https://doi.org/10.1111/tpj.13255

Related works:
* **Chvan Youssef, François Bizet, Renaud Bastien, David Legland, Marie-Béatrice Bogeat-Triboulot, Irène Hummel, 2018**. Quantitative dissection of variations in root growth rate: a matter of cell proliferation or of cell expansion? *Journal of Experimental Botany* 69(21), p. 5157-5168. https://doi.org/10.1093/jxb/ery272
