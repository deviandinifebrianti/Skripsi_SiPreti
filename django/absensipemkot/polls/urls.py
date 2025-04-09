from django.urls import path
from . import views

urlpatterns = [
    # path('index/', views.index, name='index'),  # Halaman utama
    path('add_image/', views.add_image, name='add_image'),  # Menambahkan '/' di akhir
]