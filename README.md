port miui telephony
==================

工具说明：
------------------
1.本工具用于miui6 patchrom适配机型移植小米手机的通信层

2.移植后，可以修复一些bug

使用方法：
----------
1.将底包的framework-res.apk放到stockrom/system/framework下

2.将小米手机的对应的apk和jar放到xiaomi/system文件夹的对应位置

3.使用脚本开始移植

     ./port.sh

4.运行完成后，临时目录下的overlay文件夹内的smali用于覆盖对应jar中的smali，临时目录下apk用于直接替换对应的apk

注意事项：
-------
1.overlay中的smali可能编译报错，需要将const/high16修改成const

感谢：
-------
miui合作开发组各位大神的研究
