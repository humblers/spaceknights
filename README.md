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
* for all server build, run following command in root directory  
```./gradlew buildServer```  
or  
```gradlew.bat buildServer```  
* build specific project, run in root dir  
```./gradlew link```  
* then, run in `<PROJECT_DIR>`  
```./gradlew build```  

#### run  
* for windows, execute <run-server-win.bat>
* for linux  
```
./gradlew copyExecutable
```
* then, run binaries in bin directory

