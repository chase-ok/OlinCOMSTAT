""" 
Used as an easier bridge for matlab to read the images produced by the confocal.
Now that we're using our own runComstat function, much of this is redundant
(renaming, generation of .info file). However, it's left in in case we have to
run comstat manually.

It takes 3 arguments, the base directory of the data files, the image series 
number and the channel number to use.

It will copy the specified images from the base directory into the current 
directory with COMSTAT-approved names.

It will print the following to stdout (assuming correct inputs), one line at a 
time:
    Voxel size in x, y, and z,
    Image files (in order)
    
Usage:
    python comstat.py BASE_DIR SERIES_NUM CHANNEL_NUM
"""
 

import sys
import os.path
import shutil
from xml.dom import minidom
from optparse import OptionParser

def createInfoFile(props):
    """
    Takes a props dict created from readProps and writes a comstat-readable info
    file.
    """
    info = \
    """Range
        #0#
        #{0:d}#   numImages-1
        PixelSize(x)
        #{1:f}#
        PixelSize(y)
        #{2:f}#
        PixelSize(z)
        #{3:f}#
    """.format(props['numImages']-1, *props['voxel'])
    
    infoPath = getInfoPath(props['seriesNum'])
    #if os.path.isfile(infoPath):
    #    print 'Warning: overriding existing .info file.'
    with open(infoPath, 'w') as f: f.write(info)
    
def readProps(baseDir, seriesNum, channelNum):
    """
    Returns a dictionary of the relevant properties for a series from the
    Properties.xml file.
    
    Included properties:
        - seriesNum
        - numSlices
        - voxel (tuple of x, y, z)
        - imageSize (tuple of width, height)
    
    NOTE: all in micrometers
    """
    props = { 'baseDir': baseDir, 'seriesNum': seriesNum, \
              'channelNum': channelNum }
    
    xml = minidom.parse(getPropsPath(baseDir, seriesNum))
    
    dimensions = xml.getElementsByTagName('DimensionDescription')
    
    props['numImages'] = int(dimensions[2].attributes['NumberOfElements'].value)
    
    def parse_voxel(index): 
        return float(dimensions[index].attributes['Voxel'].value)
    props['voxel'] = (parse_voxel(0), parse_voxel(1), parse_voxel(2))
    
    def parse_length(index):
        return float(dimensions[index].attributes['Length'].value)
    props['imageSize'] = (parse_length(0), parse_length(1))
    
    return props

def getPropsPath(baseDir, seriesNum):
    """ Returns the path to the props file based on the series number. """
    fileName = 'Series{0:03d}_Properties.xml'.format(seriesNum)
    path = os.path.join(baseDir, fileName)
    assert os.path.isfile(path), 'Properties file does not exist!'
    return path

def getInfoPath(seriesNum):
    """ Returns the path to the info file based on the series number. """
    return 'Series{0:03d}_z.info'.format(seriesNum)

def getOriginalTifPath(props, imageNum):
    """ Returns the path to the original .tif file based on the image num. """
    if props['numImages'] < 100:
        numDigits = 2
    else:
        numDigits = 3
    imageStr = str(imageNum).zfill(numDigits)
    fileName = 'Series{0:03d}_z{1}_ch{2:02d}.tif'.format(props['seriesNum'], \
                imageStr, props['channelNum'])
    return os.path.join(props['baseDir'], fileName)

def getComstatTifPath(props, imageNum):
    """ Returns the comstat path for a .tif file based on the image num. """
    return 'Series{0:03d}_z{1:d}.tif'.format(props['seriesNum'], imageNum)

def renameImages(props):
    """ 
    Tries to rename every image in the series to comstat-acceptable version. 
    """
    for n in range(0, props['numImages']):
        shutil.copy(getOriginalTifPath(props, n), getComstatTifPath(props, n))

def printImageNames(props):
    """ Prints all of the comstat image paths to stdout. """
    for n in range(0, props['numImages']):
        print getComstatTifPath(props, n)

def printImportantProps(props):
    """ Prints the props needed by MATLAB. """
    x, y, z = props['voxel']
    print x
    print y
    print z

def main():
    usage = 'usage: %prog <baseDir> <seriesNum> <channelNum>'
    
    parser = OptionParser(usage)
    (options, args) = parser.parse_args()
    
    if len(args) != 3:
        parser.print_usage()
        sys.exit(0)
    
    baseDir = args[0]
    seriesNum = int(args[1])
    channelNum = int(args[2])
    
    props = readProps(baseDir, seriesNum, channelNum)
    createInfoFile(props)
    renameImages(props)
    
    printImportantProps(props)
    printImageNames(props)
    
if __name__ == '__main__': main()
