우주기사 프로젝트 저장소
=============
## Editor setting

### Art Re-import
v2.1 기준으로 obj파일에서 mesh를 가져올 때 msh파일에 집어넣는 obj파일 경로에대한 해쉬값(확실치않음)이 Windows와 Mac에서 다르게 계산된다  
이 때문에 Automatic Re-import를 켜두면 작업하는 머신에 따라 프로젝트를 열거나 씬이 갱신될 때 msh파일이 계속 바뀐것으로 나오는 불편함이 있다  
더군다나 이 re-import시에 mesh안에 surface관련 설정들이 날아가버리는 경우가 있어서 특정 케이스에서는 아예 버그도 발생한다  
따라서 꺼두는게 속편함

#### disable auto re-import step
![open_editor_setting](https://files.slack.com/files-tmb/T4KHKQQKA-F4TTP8TAA-78d90d428b/pasted_image_at_2017_04_02_08_03_pm_360.png)