from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.forms.models import model_to_dict
import os
from django.conf import settings
from .models import Biometrik
from .face_recognition import main
from django.conf import settings
import time
from django.views.decorators.http import require_http_methods
from django.contrib.auth.models import User


path_dataset = settings.MEDIA_ROOT+"/media/dataset/"
# Create your views here.
@csrf_exempt
def add_image(request):
    # time.sleep(3)
    if request.method == 'POST':
        url_image = request.POST['url_image']
        id_pegawai = request.POST['id_pegawai']
        name = request.POST['name']

        file_name = str(id_pegawai)
        biometrik = Biometrik.objects.filter(id_pegawai=id_pegawai)
        if(biometrik.count()==0):
            # print("data tidak ada. 0")
            url_image_array = [url_image]
            adding_face = main.add_face(url_image_array,file_name)
        else:
            # print("data ada. > 1")
            url_image_array = []
            for data_bio in biometrik:
                url_image_array.append(data_bio.image)
            url_image_array.append(url_image)
            adding_face = main.add_face(url_image_array,file_name)

            if(adding_face==False):
                url_image_array.remove(url_image)
                main.add_face(url_image_array,file_name)

        if(adding_face):
            face_id = insert_image_db(id_pegawai,name,url_image)
            for row in Biometrik.objects.all():
                if Biometrik.objects.filter(image=row.image).count() > 1:
                    row.delete()
            response = {'status':1,'message':"Berhasil","face_id":face_id}
        else:
            response = {'status':0,'message':"Gagal"}
        
        print(response)
        return JsonResponse(response) 

def insert_image_db(id_pegawai,name,url_image):
    # insert image
    insert_biometrik = Biometrik.objects.create(
        id_pegawai = id_pegawai,
        name = name,
        image = url_image
    )
    insert_biometrik.save()
    id_biometrik = insert_biometrik.id_pegawai
    face_id = str(id_pegawai)+"."+str(id_biometrik)
    # update image
    Biometrik.objects.filter(id_pegawai=id_biometrik).update(
        face_id=face_id
    )
    return face_id

@csrf_exempt
def edit_image(request):
    time.sleep(3)
    face_id = request.POST['face_id']
    url_image = request.POST['url_image']
    name = request.POST['name']

    biometrik = Biometrik.objects.filter(face_id=face_id)
    if(biometrik.count()==0):
        response = {'status':2,'message':"Gagal. Data Face_id Tidak Ditemukan."}
    else:
        id_pegawai = str(biometrik[0].id_pegawai)
        file_name = str(id_pegawai)
        biometrik_new = Biometrik.objects.filter(id_pegawai=id_pegawai).exclude(face_id=face_id)
        url_image_array = []
        if(biometrik_new.count()>0):
            for data_bio in biometrik_new:
                url_image_array.append(data_bio.image)
            url_image_array.append(url_image)
        else:
           url_image_array.append(url_image) 
        adding_face = main.add_face(url_image_array,file_name)

        if(adding_face==False):
            url_image_array = []
            biometrik_new2 = Biometrik.objects.filter(id_pegawai=id_pegawai)
    
            if(biometrik_new2.count()>0):
                for data_bio in biometrik_new2:
                    url_image_array.append(data_bio.image)
                # print(url_image_array)
                main.add_face(url_image_array,file_name)

        if(adding_face):
            face_id = update_image_db(face_id,name,url_image)
            response = {'status':1,'message':"Berhasil","face_id":face_id}
        else:
            response = {'status':0,'message':"Gagal"}
    print(response)
    return JsonResponse(response) 

def update_image_db(face_id,name,url_image):
    biometrik = Biometrik.objects.filter(face_id=face_id)
    biometrik.update(name=name,image=url_image)
    return biometrik[0].face_id

@csrf_exempt
def hapus_image(request):
    time.sleep(3)
    face_id = request.POST['face_id']
    biometrik = Biometrik.objects.filter(face_id=face_id)
    if(biometrik.count()>0):
        id_pegawai = str(biometrik[0].id_pegawai)

        # hapus db
        delete = biometrik.delete()

        # cek biometrik ada berapa
        biometrik_new = Biometrik.objects.filter(id_pegawai=id_pegawai)
        if(biometrik_new.count()==0):
            if(os.path.exists(path_dataset+id_pegawai+'.txt')):
                os.remove(path_dataset+id_pegawai+'.txt')
        else:
            url_image_array = []
            for data_bio in biometrik_new:
                url_image_array.append(data_bio.image)
            file_name = str(id_pegawai)
            adding_face = main.add_face(url_image_array,file_name)

        if(delete):
            response = {'status':1,'message':"Berhasil."}
        else:
            response = {'status':0,'message':"Gagal."}
    else:
        response = {'status':0,'message':"Gagal. face_id tidak ditemukan"}
    print(response)
    return JsonResponse(response) 

@csrf_exempt
def verify_image(request):
    url_image = request.POST['url_image']
    id_pegawai = request.POST['id_pegawai']
    biometrik = Biometrik.objects.filter(id_pegawai=id_pegawai)
    if(biometrik.count()>0):
        cek_image = main.verify_face(url_image,id_pegawai)

        if(cek_image):
            response = {'status':1,'message':"Cocok."}
        else:
            response = {'status':0,'message':"Tidak Cocok."}
    else:
        response = {'status':0,'message':"Id Pegawai Tidak ditemukan."}
    print(response)
    return JsonResponse(response) 