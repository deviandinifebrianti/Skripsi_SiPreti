from django.db import models

# Create your models here.
# Create your models here.
class Biometrik(models.Model):
    id_pegawai = models.AutoField(primary_key=True)
    name = models.CharField(max_length=200)
    image = models.TextField()
    face_id = models.CharField(max_length=200,blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name

    class Meta:
        db_table = "sipreti_biometrik"
# class Biometrik(models.Model):                            