from django.conf.urls import url
from . import views


urlpatterns = [
    # url(r'^$', views.index),
    url(r'add_image', views.add_image),
    url(r'edit_image', views.edit_image),
    url(r'hapus_image', views.hapus_image),
    url(r'verify_image', views.verify_image)
]

# from django.contrib import admin
# from django.urls import path, include

# urlpatterns = [
#     path('admin/', admin.site.urls),
# ]

# from django.urls import path
# from django.urls import path
# from . import views
# # from .views import add_image, edit_image, hapus_image, verify_image

# urlpatterns = [
#     path('add_image/', views.add_image, name='add_image'),
#     path('edit_image/', views.edit_image, name='edit_image'),
#     path('hapus_image/', views.hapus_image, name='hapus_image'),
#     path('verify_image/', views.verify_image, name='verify_image'),
# ]

# for url in urlpatterns:
#     print(url.pattern)