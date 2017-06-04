Prerequisite
============
* Xcode, Apple developer account(Enterprise is good to test), executable ios godot editor, ![export template](https://downloads.tuxfamily.org/godotengine/2.1.3/Godot_v2.1.3-stable_export_templates.tpz)

Download and Install template
============
* install template in godot editor(settings -> install export templates -> choose downloaded tpz file)

Build executable ios editor
============
* build
```bash
scons platform=iphone target=debug
```
* replace executable editor to ![../godot_ios_xcode/godot.iphone.debug.arm]()

Make .pck file
============
* open editor in OSX
* click export button(left top)
* choose any platform U can export pck
* then export
* replace .pck file to ![../godot_ios_xcode/data.pck]()

Xcode
============
* open godot_ios_xcode.proj in Xcode
* set account and provisioning profile
* run godot_ios!!


