'''
@Author: David Vu
Run the pretrained model to extract 128D face features
'''

import tensorflow as tf
from .architecture import inception_resnet_v1 as resnet
from tensorflow.python.platform import gfile
import numpy as np
import os
from django.conf import settings
import re
from django.conf import settings


class FaceFeature(object):
    def __init__(self, face_rec_graph, model_path=None):
        if model_path is None:
            model_path = os.path.join(settings.MEDIA_ROOT, 'models', '20170512-110547.pb')
        
        # Periksa apakah file ada
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"File tidak ditemukan: {model_path}")
        
        self.face_rec_graph = face_rec_graph
        self.model_path = model_path

        '''

        :param face_rec_sess: FaceRecSession object
        :param model_path:
        '''
        # print("Loading model...")
        with face_rec_graph.graph.as_default():
            self.sess = tf.compat.v1.Session()
            with self.sess.as_default():
                self.__load_model(model_path)
                self.x = tf.compat.v1.get_default_graph() \
                                    .get_tensor_by_name("input:0")
                self.embeddings = tf.compat.v1.get_default_graph() \
                                    .get_tensor_by_name("embeddings:0")
                self.phase_train_placeholder = tf.compat.v1.get_default_graph() \
                                                     .get_tensor_by_name("phase_train:0")                    

                def __load_model(self, model_path):
                    # Muat model dari file .pb
                    with tf.io.gfile.GFile(model_path, 'rb') as f:
                        graph_def = tf.compat.v1.GraphDef()
                        graph_def.ParseFromString(f.read())
                        tf.compat.v1.import_graph_def(graph_def, name='')

                    # Contoh penggunaan
                    model_path = os.path.join(settings.BASE_DIR, "media/models/20170512-110547.pb")
                    # your_instance = YourClass(model_path)


    def get_features(self, input_imgs):
        images = load_data_list(input_imgs,160)
        feed_dict = {self.x: images, self.phase_train_placeholder: False}

        return self.sess.run(self.embeddings, feed_dict = feed_dict)



    def __load_model(self, model):
        # Check if the model is a model directory (containing a metagraph and a checkpoint file)
        #  or if it is a protobuf file with a frozen graph
        model_exp = os.path.expanduser(model)
        if os.path.isfile(model_exp):
            # print('Model filename: %s' % model_exp)
            model_path = "media/models/20170512-110547.pb"

            with tf.io.gfile.GFile(model_path, 'rb') as f:
                graph_def = tf.compat.v1.GraphDef()
                graph_def.ParseFromString(f.read())
                tf.import_graph_def(graph_def, name='')
        else:
            # print('Model directory: %s' % model_exp)
            meta_file, ckpt_file = get_model_filenames(model_exp)
            # print('Metagraph file: %s' % meta_file)
            # print('Checkpoint file: %s' % ckpt_file)
            saver = tf.compat.v1.train.import_meta_graph(os.path.join(model_exp, meta_file))
            with tf.compat.v1.Session() as sess:
                saver.restore(sess, os.path.join(model_exp, ckpt_file))


def get_model_filenames(model_dir):
    files = os.listdir(model_dir)
    meta_files = [s for s in files if s.endswith('.meta')]
    if len(meta_files) == 0:
        raise ValueError('No meta file found in the model directory (%s)' % model_dir)
    elif len(meta_files) > 1:
        raise ValueError('There should not be more than one meta file \
                                    in the model directory (%s)' % model_dir)
    meta_file = meta_files[0]
    meta_files = [s for s in files if '.ckpt' in s]
    max_step = -1
    for file_ in files:
        step_str = re.match(r'(^model-[\w\- ]+.ckpt-(\d+))', file_)
        if step_str is not None and len(step_str.groups()) >= 2:
            step = int(step_str.groups()[1])
            if step > max_step:
                max_step = step
                ckpt_file = step_str.groups()[0]
    return meta_file, ckpt_file

def tensorization(img):
    '''
    Prepare the imgs before input into model
    :param img: Single face image
    :return tensor: numpy array in shape(n, 160, 160, 3) ready for input to cnn
    '''
    # tensor = img.reshape(-1, Config.Align.IMAGE_SIZE, Config.Align.IMAGE_SIZE, 3)
    # return tensor
    Config = {
        "Align": {
            "IMAGE_SIZE": 160
        }
    }

    # Sekarang Anda bisa menggunakan Config["Align"]["IMAGE_SIZE"]
    tensor = img.reshape(-1, Config["Align"]["IMAGE_SIZE"], Config["Align"]["IMAGE_SIZE"], 3)
    return tensor

#some image preprocess stuff
def prewhiten(x):
    mean = np.mean(x)
    std = np.std(x)
    std_adj = np.maximum(std, 1.0 / np.sqrt(x.size))
    y = np.multiply(np.subtract(x, mean), 1 / std_adj)
    return y

def load_data_list(imgList, image_size, do_prewhiten=True):
    images = np.zeros((len(imgList), image_size, image_size, 3))
    i = 0
    for img in imgList:
        if img is not None:
            if do_prewhiten:
                img = prewhiten(img)
            images[i, :, :, :] = img
            i += 1
    return images
