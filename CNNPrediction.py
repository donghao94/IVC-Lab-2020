import tensorflow as tf
from   tensorflow import keras
from tensorflow.keras import layers, Sequential
import os
import matplotlib.pyplot as plt
import numpy as np

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
tf.random.set_seed(2345)

class BasicBlock(layers.Layer):

    def __init__(self, FilterNum, stride=1):
        super(BasicBlock, self).__init__()

        self.Conv1 = layers.Conv2D(FilterNum, (3, 3), strides=stride, padding='same')
        self.BathNormaliz1 = layers.BatchNormalization()
        self.ReLu = layers.Activation('relu')
        self.Conv2 = layers.Conv2D(FilterNum, (3, 3), strides=1, padding='same')
        self.BathNormaliz2 = layers.BatchNormalization()
        self.downsample = lambda x:x



    def call(self, Inputs, training=None):
        
        Out = self.Conv1(Inputs)
        Out = self.BathNormaliz1(Out)	
        Out = self.ReLu(Out)
        Out = self.Conv2(Out)
        Out = self.BathNormaliz2(Out)
        Identity = Inputs
        Output = layers.add([Out, Identity])
        Output = tf.nn.relu(Output)

        return Output


class ResNet(keras.Model):


    def __init__(self, Blocks): #
        super(ResNet, self).__init__()

        self.FirstStep = Sequential([layers.Conv2D(64, (3, 3), strides=(1, 1),
                                padding = 'same'),
                                layers.BatchNormalization(),
                                layers.Activation('relu')
                                ])

        self.Res = Sequential()
        # may down sample

        for _ in range(Blocks):
            self.Res.add(BasicBlock(64, stride=1))

        # output: [b, 96, 96, 3],
        self.LastStep = Sequential([layers.Conv2D(3, (3, 3), strides=(1, 1),
                                padding = 'same'),
                                layers.BatchNormalization(),
                                layers.Activation('tanh')
                                ])





    def call(self, Inputs, training=None):

        a = self.FirstStep(Inputs)

        a = self.Res(a)

        a = self.LastStep(a)

        return a
    
def mkdir(path):
    isExists=os.path.exists(path)
    if not isExists:
        os.makedirs(path) 

def main():

    Model = ResNet(16)
    Model.build(input_shape=(None, 96, 96, 3))
    Model.summary()

    PathBlockStill = "./Block/Still/"
    PathBlockVideo = "./Block/Video/"

    QP = [0.07, 0.1, 0.2, 0.4, 0.8, 1, 1.5, 2, 3, 4, 4.5]

    for i in range(11):

        if QP[i] <= 0.4:
            Model.load_weights("./CNNWeights/StillQP0.1.h5")
        elif QP[i] <= 1:
            Model.load_weights("./CNNWeights/StillQP1.0.h5")
        else:
            Model.load_weights("./CNNWeights/StillQP2.0.h5")



        for filename in os.listdir(PathBlockStill + "QP" + str(QP[i])):


            CurrentBlock1 = plt.imread(PathBlockStill + "QP" + str(QP[i])+ "/" + filename)
            CurrentBlock1 = 2 * tf.cast(CurrentBlock1, dtype = tf.float32) / 127. - 1
            CurrentBlock1 = tf.reshape(CurrentBlock1, [1, 96, 96, 3])
            ProcessedBlock1 = Model(CurrentBlock1)
            ProcessedBlock1 = tf.reshape(ProcessedBlock1, [96, 96, 3])
            ProcessedBlock1 = 127.5*(ProcessedBlock1 + 1)
            OutputBlock1 = tf.cast(ProcessedBlock1,dtype=tf.uint8)
            OutputBlock1 = np.array(OutputBlock1)
            
            mkpath=("./CNNBlock/Still/QP" + str(QP[i])+ "/")
            mkdir(mkpath)    
            plt.imsave(mkpath + filename,OutputBlock1)


    for i in range(11):

        if QP[i] <= 0.4:
            Model.load_weights("./CNNWeights/VideoQP0.1.h5")
        elif QP[i] <= 1:
            Model.load_weights("./CNNWeights/VideoQP1.0.h5")
        else:
            Model.load_weights("./CNNWeights/VideoQP2.0.h5")



        for filename in os.listdir(PathBlockVideo + "QP" + str(QP[i])):
            CurrentBlock2 = plt.imread(PathBlockVideo + "QP" + str(QP[i])+ "/" + filename)
            CurrentBlock2 = 2 * tf.cast(CurrentBlock2, dtype = tf.float32) / 127. - 1
            CurrentBlock2 = tf.reshape(CurrentBlock2, [1, 96, 96, 3])
            ProcessedBlock2 = Model(CurrentBlock2)
            ProcessedBlock2  = tf.reshape(ProcessedBlock2 , [96, 96, 3])
            ProcessedBlock2  = 127.5*(ProcessedBlock2 + 1)
            OutputBlock2 = tf.cast(ProcessedBlock2,dtype = tf.uint8)
            OutputBlock2 = np.array(OutputBlock2) 
                
            mkpath=("./CNNBlock/Video/QP" + str(QP[i])+ "/" )
            mkdir(mkpath)    
            plt.imsave(mkpath + filename,OutputBlock2)


if __name__ == '__main__':
    main()