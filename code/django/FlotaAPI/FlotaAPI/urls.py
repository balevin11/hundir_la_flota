"""
URL configuration for FlotaAPI project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from flotaapp import endpoint_matchmaking  as mm
from flotaapp import endpoint_ranking as rk
from flotaapp import endpoint_login
from flotaapp import register_endpoint
from flotaapp import endpoint_loading_game
from flotaapp import endpoint_turn

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/1/matchmaking', mm.matchmaking),
    path('api/1/sessions', endpoint_login.login),
    path('api/1/ranking', rk.ranking),
    path('api/1/users', register_endpoint.register),
    path('api/1/partida/<int:partida_id>', endpoint_loading_game.cargar_partida),
    path('api/1/partida/<int:partida_id>/turno', endpoint_turn.turno),

]
