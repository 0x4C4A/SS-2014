# -*- coding: utf-8 -*-
# Signāli un sistēmas. 3. Laboratorijas darbs
# == Taisnstūra loga ietekme uz signāla spektur ==
import sys
import numpy as np
import matplotlib.pyplot as plt
from PyQt4 import QtGui, QtCore
from scipy.fftpack import fft
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar



class Window(QtGui.QDialog):
    def __init__(self, parent=None):
        super(Window, self).__init__(parent)

        # a figure instance to plot on
        self.figure = plt.figure()
        # this is the Canvas Widget that displays the `figure`
        # it takes the `figure` instance as a parameter to __init__
        self.canvas = FigureCanvas(self.figure)
        # this is the Navigation widget
        # it takes the Canvas widget and a parent
        self.toolbar = NavigationToolbar(self.canvas, self)
        # make slidebar
        sld = QtGui.QSlider(QtCore.Qt.Horizontal, self)
        sld.setFocusPolicy(QtCore.Qt.NoFocus)
        sld.setGeometry(30, 40, 100, 30)
        sld.setMaximum(20)
        sld.setMinimum(1)
        sld.valueChanged[int].connect(self.changeValue)
        self.setWindowTitle('Singnala spektra atkariba no taisnstura loga platuma')

        # set the layout
        layout = QtGui.QVBoxLayout()
        layout.addWidget(self.toolbar)
        layout.addWidget(self.canvas)
        layout.addWidget(sld)
        self.setLayout(layout)

    def changeValue(self, value):
        ''' plot '''
        T = value/10.
        x = np.linspace(0, T, samples)
        y = np.sin(2*np.pi*x)
        # create an axis
        sign = self.figure.add_subplot(211)
        spectr = self.figure.add_subplot(212)
        # discards the old graph
        sign.hold(False)
        spectr.hold(False)
        S = fft(y)/samples
        sampRate = samples/T
        fs = np.arange(0, sampRate, 1/T)
        # plot data
        sign.plot(x, y, '.k')
        spectr.plot(fs, abs(S), '.k')
        spectr.axis([0, 10, 0, 0.8])
        spectr.grid(b = True)
        # refresh canvas
        self.canvas.draw()

if __name__ == '__main__':
    app = QtGui.QApplication(sys.argv)
    # Siulācijas laika patametri
    samples  = 128
    main = Window()
    main.show()

    sys.exit(app.exec_())

