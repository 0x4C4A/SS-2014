
from PyQt4 import QtCore, QtGui 
import pyqtgraph as pg
import math
import serial

def binRev( num, length ):
    rev_num = 0
    count = length
    while num > 0:
      rev_num <<= 1
      rev_num  |= num & 0x01
      num >>= 1
      count -= 1

    return rev_num << count

def binToGray( num ):
    return (num >> 1) ^ num

def HadamardToWalsh( num,  length ):
    return binToGray(binRev(num, length))


def Hadamard_matrix_gen( matrix_order ):
    matrix_size = pow(2,matrix_order);

    #Allocate array
    matrix = [[0 for x in xrange(matrix_size)] for x in xrange(matrix_size)] 

    matrix[0][0] = 1

    for stage in range(0,int(math.log(matrix_size,2))):
        block_edge = pow(2, stage)
        for x in range(0, block_edge):
            for y in range(0, block_edge):
                matrix[x + block_edge][y] = matrix[x][y]
                matrix[x][y + block_edge] = matrix[x][y]
                matrix[x + block_edge][y + block_edge] = -matrix[x][y]

    return matrix


def Walsh_matrix_gen( matrix_order ):
    had_mat = Hadamard_matrix_gen( matrix_order )

    matrix_size = pow(2,matrix_order);
    matrix = [[0 for x in xrange(matrix_size)] for x in xrange(matrix_size)] 
    for y in range(0, matrix_size):
        WalshY = HadamardToWalsh(y, matrix_order)
        for x in range(0, matrix_size):
            matrix[x][WalshY] = had_mat[x][y]

    return matrix


def initViewBox( plot, xsize, ysize ):
    viewBox = plot.getViewBox()
    viewBox.setXRange( 0, xsize )
    viewBox.setYRange( -ysize, ysize )
    viewBox.disableAutoRange()
    #viewBox.setLimits(xMin = 0, xMax = xsize, yMin = -ysize, yMax = ysize)

class optWin(QtGui.QWidget):
    def __init__(self, parent=None):
        QtGui.QWidget.__init__(self, parent)
        self.setupUi(self)
        #self.button1.clicked.connect(self.handleButton)
        self.window2 = None
        self.show()

    def setupUi(self, Slider):
        Slider.resize(200, 100)
        self.slider = QtGui.QSlider(QtCore.Qt.Horizontal, Slider)
        self.slider.setTickInterval(1)

        self.slider.setGeometry(10, 10, 101, 30)

        self.sliderlabel = QtGui.QLabel(Slider)
        self.sliderlabel.setGeometry(50, 40, 101, 30)
        self.sliderlabel.setText("0")
        #QtCore.QObject.connect(self.slider, QtCore.SIGNAL('valueChanged(int)'), optWin.changeText)
        #slider.move(50,50)
        #self.button1.setGeometry(QtCore.QRect(50, 30, 99, 23))

def updateIfwht( arrSpect ):
    arrResult = []
    arrSpectWalsh = [0 for x in xrange(len(arrSpect))]

    for i in range(0, len(arrSpect)):
        arrSpectWalsh[HadamardToWalsh(i,5)] = arrSpect[i]
    #Reproduce the original signal from the received spectrum
    for i in range(0, len(arrSpect)):
        result = 0
        for j in range(0, int(round((win2.slider.value()/99.0)*len(arrSpect)))):
            indice = HadamardToWalsh(j, 5)
            result += arrSpectWalsh[j]*ifwht_matrix[i][j]
        arrResult.append(result/len(arrSpect) )

    win2.sliderlabel.setText(str(round((win2.slider.value()/100.0)*len(arrSpect))))
    p3.plot(range(0,len(arrResult)),arrResult,clear = True)


# Connect to Serial port
uart_port = raw_input("Enter the port to use: ");
if uart_port == "":
    uart_port = "/dev/ttyUSB0";

print "Attempting to connect to", uart_port, "."
ser = serial.Serial(uart_port,115200, timeout = 0.02)



# Set up the plots
app = QtGui.QApplication([])
win2 = optWin()
win = pg.GraphicsWindow(title="Spectrum & signal")
p1 = win.addPlot(row = 1, col = 1, colspan = 2, title="Spectrum")
p2 = win.addPlot(row = 2, col = 1, title="Oscillogram")
p3 = win.addPlot(row = 2, col = 2, title="Oscillogram - recreated")

initViewBox(p1, 32, 255)
initViewBox(p2, 32, 127)
initViewBox(p3, 32, 127)

ifwht_matrix = Walsh_matrix_gen(5)

arrSpect = []
while True:
    print "Reading 128 bytess!"
    x = ser.read(128)
    while len(x) < 128:
        x = ser.read(128)
        updateIfwht( arrSpect )
        pg.QtGui.QApplication.processEvents()
    #print repr(x)

    arrSpect = []
    arrOsc = []
    #Reproduce received data
    for i in range(0,len(x)/4):
        arrSpect.append(ord(list(x)[i*2])+ord(list(x)[i*2+1])*256)
        arrOsc.append( (ord(list(x)[(i+32)*2])+ord(list(x)[(i+32)*2+1])*256) - 127)
        if arrSpect[i]>32767:
            arrSpect[i] -= 65535
        if arrOsc[i]>32767:
            arrOsc[i] -=65535
    
    arrSpect[0] = 0
    updateIfwht( arrSpect )
    p1.plot(range(0,len(arrSpect)),arrSpect,clear = True)   
    p2.plot(range(0,len(arrOsc)),arrOsc,clear = True)
    
    pg.QtGui.QApplication.processEvents()
