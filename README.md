우주기사 프로젝트 저장소
=============
## Godot
### Editor settings

#### [Art Re-import](/documents/resource_reimport.md)

#### [Run game in iOS](/documents/run_ios.md)

## Golang
### Gogradle

#### requirements  
* jdk8+
* if using IDEs(Gogland, Android Studio, etc...). jdk already installed.
* on mac  
```/Applications/<PRODUCT>.app/Contents/jdk/Contents/Home/jre```
* on windows  
```<INSTALLATION PATH OF IDE>/jre/jre```  

#### build
* run following command in go main directory  
```
./gradlew build
```
or
```
gradlew.bat build
```
* execute file in gogradle directory(in linux)
* file name is combination of os/project_name(such as drawin_amd64_lobby)  
```
.gogradle/<OS>_<PACKAGENAME>
```
