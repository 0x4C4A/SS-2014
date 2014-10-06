# -*- coding: utf-8 -*-
# Signāli un sistēmas. 3. Laboratorijas darbs
# == Taisnstūra loga ietekme uz signāla spektru ==
# (Nuļļu pievienošanas ietekme)
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
        self.setWindowTitle('Singnala spektra atkariba no taisnstura loga platuma')
        # this is the Canvas Widget that displays the `figure`
        # it takes the `figure` instance as a parameter to __init__
        self.canvas = FigureCanvas(self.figure)
        # this is the Navigation widget
        # it takes the Canvas widget and a parent
        self.toolbar = NavigationToolbar(self.canvas, self)
        # Make a slidebar
        sld = QtGui.QSlider(QtCore.Qt.Horizontal, self)
        sld.setFocusPolicy(QtCore.Qt.StrongFocus)
        sld.setGeometry(30, 40, 200, 30)
        sld.setMaximum(30)
        sld.setMinimum(0)
        sld.setTickInterval(1)
        sld.setTickPosition(2)
        sld.setValue(20)

        sld.valueChanged[int].connect(self.changeValue)
        # Make a Line Edit widget
        self.qle = QtGui.QLineEdit(self)
        self.qle.setReadOnly(1)
        #self.qle.insert('Taisnstura loga platums:')
        # set the layout
        layout = QtGui.QVBoxLayout()
        layout.addWidget(self.toolbar)
        layout.addWidget(self.canvas)
        layout.addWidget(sld)
        layout.addWidget(self.qle)
        self.setLayout(layout)

    def changeValue(self, value):
        ''' Reakcija uz slidinashanu '''
        # Logots signāls
        width = round(value/10.*sampRate, 0)
        x  = np.arange(0, T, sampTime)
        y1 = np.sin(2*np.pi*x[0:width])
        y2 = np.zeros(samples-len(y1))
        y  = np.append(y1, y2)
        # Spektrs
        S = fft(y)/samples
        fs = np.arange(0, sampRate, 1/T)
        # plot 
        sign = self.figure.add_subplot(211)
        spectr = self.figure.add_subplot(212)
        # Atceļ veco
        sign.hold(False)
        spectr.hold(False)
        # Uzliek jauno
        sign.plot(x, y, '.-k')
        sign.legend(['Ierobezots signals'], 1)
        spectr.plot(fs, abs(S), '.k')
        spectr.legend(['Signala spektrs'], 1)
        spectr.axis([0., 5., 0, 0.8])
        spectr.grid(b = True), sign.grid(b = True)
        # Papildina Line Edit widget ar loga platumu
        t = 'Taisnstura loga platums: {}xT'.format(round(width*sampTime, 1))
        self.qle.setSelection(0, 2*len(t))
        self.qle.insert(t)
        # Atjauno canvas
        self.canvas.draw()

if __name__ == '__main__':
    app = QtGui.QApplication(sys.argv)
    # Siulācijas laika patametri
    T        = 3.
    samples  = 128
    sampRate = samples/T
    sampTime = 1/sampRate
    # GUI
    main = Window()
    main.changeValue(20)
    main.show()

    sys.exit(app.exec_())




