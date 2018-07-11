# Docker pour NIFI - Contexte Saagie

## Update du code NIFI

Projet: https://github.com/bbonnin/nifi-rel-nifi-1.6.0

* Classe nifi-rel-nifi-1.6.0/nifi-nar-bundles/nifi-framework-bundle/nifi-framework/nifi-web/nifi-web-api/src/main/java/org/apache/nifi/web/api/ApplicationResource.java
  * mise à jour du scheme/host/port si NIFI4SAAGIE est actif

* Builder le projet `nifi-rel-nifi-1.6.0` et copier le fichier `nifi-framework-nar-1.6.0.nar` à la racine de ce projet

## Build

```sh
./docker build
```

