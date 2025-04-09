from django.shortcuts import render
from django.http import HttpResponse
from django.http import Http404 
from django.views import View

def index(request):
    return render(request, 'polls/index.html')

def add_image(request):
    return render(request, 'polls/add_image.html')