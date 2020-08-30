import tensorflow as tf
from    tensorflow import keras
from tensorflow.keras import layers, optimizers, datasets, Sequential
import os
import matplotlib.pyplot as plt
import numpy as np

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
tf.random.set_seed(2345)

class BasicBlock(layers.Layer):

    def __init__(self, filter_num, stride=1):
        super(BasicBlock, self).__init__()

        self.conv1 = layers.Conv2D(filter_num, (3, 3), strides=stride, padding='same')
        self.bn1 = layers.BatchNormalization()
        self.relu = layers.Activation('relu')
        self.conv2 = layers.Conv2D(filter_num, (3, 3), strides=1, padding='same')
        self.bn2 = layers.BatchNormalization()


        self.downsample = lambda x:x



    def call(self, inputs, training=None):

        # [b, h, w, c]
        out = self.conv1(inputs)
        out = self.bn1(out)
        out = self.relu(out)

        out = self.conv2(out)
        out = self.bn2(out)

        identity = self.downsample(inputs)

        output = layers.add([out, identity])
        output = tf.nn.relu(output)

        return output


class ResNet(keras.Model):


    def __init__(self, blocks): #
        super(ResNet, self).__init__()

        self.stem = Sequential([layers.Conv2D(64, (3, 3), strides=(1, 1),
                                padding = 'same'),
                                layers.BatchNormalization(),
                                layers.Activation('relu')
                                ])

        self.res_blocks = Sequential()
        # may down sample

        for _ in range(blocks):
            self.res_blocks.add(BasicBlock(64, stride=1))

        # output: [b, 96, 96, 3],
        self.final = Sequential([layers.Conv2D(3, (3, 3), strides=(1, 1),
                                padding = 'same'),
                                layers.BatchNormalization()
                                ])







    def call(self, inputs, training=None):

        x = self.stem(inputs)

        x = self.res_blocks(x)

        x = self.final(x)

        x = tf.nn.tanh(x)

        return x




def main():

    model = ResNet(16)
    model.build(input_shape=(None, 96, 96, 3))
    model.summary()

    optimizer = tf.optimizers.Adam(lr=1e-4)

    path_input = "img/Block_QP0.2/"
    path_lebel = "img/Or_foreman/"




    for epoch in range(300):

        for filename in os.listdir(path_input):
            filname_y = filename.replace("Block_","OriForeman_")

            x = plt.imread(path_input + filename)
            y = plt.imread(path_lebel + filname_y)
            x = 2 * tf.cast(x, dtype=tf.float32) / 127. - 1
            y = 2 * tf.cast(y, dtype=tf.float32) / 255. - 1
            y = tf.reshape(y, [1, 96, 96, 3])
            x = tf.reshape(x, [1, 96, 96, 3])


            with tf.GradientTape() as tape:
                logits = model(x)
                logits = tf.reshape(logits,[1,96*96*3])
                y = tf.reshape(y,[1,96*96*3])
                loss = tf.reduce_mean(tf.square(y-logits))

            grads = tape.gradient(loss, model.trainable_variables)
            optimizer.apply_gradients(zip(grads, model.trainable_variables))
            print(loss)
    model.save_weights("weights/weights_qp0.2.h5")


if __name__ == '__main__':
    main()
