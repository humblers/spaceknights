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
* for all server build, run following command in server directory  
```./gradlew build```  
or  
```gradlew.bat build```  
* build specific project, run in server dir  
```./gradlew build -p <PROJECT DIR>```  

#### run  
* for windows, execute `<run-server-win.bat>`
* for linux, when build succeed. check binary in `<.gogradle>` DIR
