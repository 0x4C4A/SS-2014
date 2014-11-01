# -*- coding: utf-8 -*-
# Signāli un sistēmas. 3. Laboratorijas darbs
# == Taisnstūra loga ietekme uz signāla spektru ==
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
        self.setWindowTitle('Signāla spektra atkarība no taisnstūra loga platuma'.decode('utf-8'))
        # this is the Canvas Widget that displays the `figure`
        # it takes the `figure` instance as a parameter to __init__
        self.canvas = FigureCanvas(self.figure)
        # this is the Navigation widget
        # it takes the Canvas widget and a parent
        #self.toolbar = NavigationToolbar(self.canvas, self)
        # Make a slidebar
        sld = QtGui.QSlider(QtCore.Qt.Horizontal, self)
        sld.setFocusPolicy(QtCore.Qt.StrongFocus)
        sld.setGeometry(30, 40, 200, 30)
        sld.setMaximum(T*10)
        sld.setMinimum(1)
        sld.setTickInterval(1)
        sld.setTickPosition(2)
        sld.setValue(T*10)

        sld.valueChanged[int].connect(self.changeValue)
        # Make a Line Edit widget
        self.qle = QtGui.QLineEdit(self)
        self.qle.setReadOnly(1)
        #self.qle.insert('Taisnstura loga platums:')
        # set the layout
        layout = QtGui.QVBoxLayout()
        #layout.addWidget(self.toolbar)
        layout.addWidget(self.canvas)
        layout.addWidget(sld)
        layout.addWidget(self.qle)
        self.setLayout(layout)

    def initPlots(self, value):
        ''' plot '''

        # Laika parametri
        T0 = value/10.
        sampRate0 = samples/T0
        x = np.linspace(0, T0 - T0/samples, samples)
        # Logots signāls
        y = np.sin(2*np.pi*x)+0.5*np.sin(2*np.pi*x*2)+0.25*np.sin(2*np.pi*x*3)
        # Diskrēts spektrs
        S = fft(y)/samples
        fs = np.arange(0, sampRate0, 1/T0)
        # Vienlaidu spektrs
        fx0 = np.arange(-2, 10, 0.001)
        S0  = 0.5*np.sinc(T0*(fx0-1))*0
        # plot 
        self.sign0 = self.figure.add_subplot(223)
        self.spectr0 = self.figure.add_subplot(224)
        self.sign1 = self.figure.add_subplot(221)
        self.spectr1 = self.figure.add_subplot(222)
        sign = self.sign0
        spectr = self.spectr0
        # Atceļ veco
        sign.hold(False)
        spectr.hold(False)
        # Uzliek jauno
        self.signal0 = sign.plot(x, y, '.-k')[0]
        sign.legend(['Ierobežots signals'.decode('utf-8')], 1)
        self.sign0.set_xlabel('t/T'), self.sign0.set_ylabel('Ampl.')
        self.sign1.set_xlabel('t/T'), self.sign1.set_ylabel('Ampl.')
        self.spectr0.set_xlabel('f/fs'), self.spectr0.set_ylabel('S(f)/max[S(f)]')
        self.spectr1.set_xlabel('f/fs'), self.spectr1.set_ylabel('S(f)/max[S(f)]')
        spectr.hold(True)
        self.spectrumstemmarker0, self.spectrumstemlines0, self.dontcare = spectr.stem(fs, abs(S)/max(abs(S)), linefmt='k', markerfmt='.k')
        spectr.legend(['Signala spektrs'.decode('utf-8')], 1)
        #self.spectrumplot0 = spectr.plot(fx0, abs(S0), '-.b')[0]
        #spectr.plot([0, sampRate0], [0.5, 0.5],[0, sampRate0], [0.25, 0.25],[0, sampRate0], [0.125, 0.125])
        spectr.axis([0., 6., 0, 1.1]), sign.axis([0, max(x), -2, 2])
        spectr.grid(b = True, which='both', linewidth=1), sign.grid(b = True)
        
##########################################################################
        sign = self.sign1
        spectr = self.spectr1

        # Logots signāls
        width = round(value/10.*sampRate, 0)
        x  = np.arange(0, T, sampTime)
        y1 = np.sin(2*np.pi*x[0:width])+0.5*np.sin(2*np.pi*x[0:width]*2)+0.25*np.sin(2*np.pi*x[0:width]*3)
        y2 = np.zeros(samples-len(y1))
        y  = np.append(y1, y2)
        # Diskrēts pektrs
        S = fft(y)/samples
        fs = np.arange(0, sampRate, 1/T)
        # Vienlaidu spektrs
        fx0 = np.arange(-2, 10, 0.001)
        S0  = 0.5*x[width-1]/T*np.sinc(x[width-1]*fx0)*0
        self.signal1 = sign.plot(x, y, '.-k')[0]
        sign.legend(['Ierobežots signals'.decode('utf-8')], 1)
        self.spectrumstemmarker1, self.spectrumstemlines1, self.dontcare = spectr.stem(fs, abs(S)/max(abs(S)), linefmt='k', markerfmt='.k')
        spectr.legend(['Signala spektrs'.decode('utf-8')], 1)
        spectr.hold(True)
        #self.spectrumplot1 = spectr.plot(fx0+1, abs(S0), '-.b')[0]
        #spectr.plot([0, sampRate0], [0.5, 0.5],[0, sampRate0], [0.25, 0.25],[0, sampRate0], [0.125, 0.125])
        spectr.axis([0., 6., 0, 1.1]), sign.axis([0, max(x), -2, 2])
        spectr.grid(b = True), sign.grid(b = True)

        # Papildina Line Edit widget ar loga platumu
        t = 'Taisnstūra loga platums: {}xT'.format(T0).decode('utf-8')
        self.qle.setSelection(0, len(t))
        self.qle.insert(t)

        # Atjauno canvas
        self.canvas.draw()
    
    def changeValue(self, value):
        ''' plot '''
        # Laika parametri
        T0 = value/10.
        sampRate0 = samples/T0
        x = np.linspace(0, T0 - T0/samples, samples)
        # Logots signāls
        y = np.sin(2*np.pi*x)+0.5*np.sin(2*np.pi*x*2)+0.25*np.sin(2*np.pi*x*3)
        # Diskrēts spektrs
        S = fft(y)/samples
        fs = np.arange(0, sampRate0, 1/T0)
        # Vienlaidu spektrs
        #fx0 = np.arange(-2, 10, 0.001)
        #S0  = 0.5*np.sinc(T0*fx0)*0
        # plot 

        # Atjaunina signāla punktus
        self.signal0.set_ydata(y)
        self.signal0.set_xdata(x)

        # Atjaunina stem punktus
        self.spectrumstemmarker0.set_xdata(fs)
        self.spectrumstemmarker0.set_ydata(abs(S)/max(abs(S)))

        # Atjaunina stem līnijas
        for line, y_new in zip(self.spectrumstemlines0, abs(S)/max(abs(S))):
            line.set_ydata([0, y_new])
        for line, x in zip(self.spectrumstemlines0, fs):
            line.set_xdata([x, x])
        #self.spectrumplot0.set_ydata(abs(S0))
        
#############################################################
        # Logots signāls
        width = round(value/10.*sampRate, 0)
        x  = np.arange(0, T, sampTime)
        y1 = np.sin(2*np.pi*x[0:width-1])+0.5*np.sin(2*np.pi*x[0:width-1]*2)+0.25*np.sin(2*np.pi*x[0:width-1]*3)
        y2 = np.zeros(samples-len(y1))
        y  = np.append(y1, y2)
        # Diskrēts pektrs
        S = fft(y)/samples
        fs = np.arange(0, sampRate, 1/T)
        # Vienlaidu spektrs
        #fx0 = np.arange(-2, 10, 0.001)
        #S0  = 0.5*x[width-1]/T*np.sinc(x[width-1]*fx0)*0

        # Atjaunina signāla punktus
        self.signal1.set_ydata(y)
        self.signal1.set_xdata(x)

        # Atjaunina stem punktus
        self.spectrumstemmarker1.set_xdata(fs)
        self.spectrumstemmarker1.set_ydata(abs(S)/max(abs(S)))

        # Atjaunina stem līnijas
        for line, y_new in zip(self.spectrumstemlines1, abs(S)/max(abs(S))):
            line.set_ydata([0, y_new])
        for line, x in zip(self.spectrumstemlines1, fs):
            line.set_xdata([x, x])
        #self.spectrumplot1.set_ydata(abs(S0))


        # Papildina Line Edit widget ar loga platumu
        t = 'Taisnstūra loga platums: {}xT'.format(T0).decode('utf-8')
        self.qle.setSelection(0, len(t))
        self.qle.insert(t)
        # Atjauno canvas
        self.canvas.draw()





if __name__ == '__main__':
    app = QtGui.QApplication(sys.argv)
    # Siulācijas laika patametri
    T        = 6.5
    samples  = 64*2
    sampRate = samples/T
    sampTime = 1/sampRate

    # GUI
    main = Window()
    main.initPlots(T*10)
    main.show()

    sys.exit(app.exec_())

