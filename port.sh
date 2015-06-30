#!/bin/bash

PORT_ROOT=$(cd `dirname $0`; pwd)
PORT_TOOLS=$PORT_ROOT/tools

APKTOOL=$PORT_TOOLS/apktool

NAME_TO_ID_TOOL=$PORT_TOOLS/nametoid
ID_TO_NAME_TOOL=$PORT_TOOLS/idtoname

XIAOMI_SYSTEM=$PORT_ROOT/xiaomi/system
STOCK_SYSTEM=$PORT_ROOT/stockrom/system
PORT_TEMP=$PORT_ROOT/port_tmp

XMLMERGYTOOL=$PORT_TOOLS/ResValuesModify/jar/ResValuesModify
GIT_APPLY=$PORT_TOOLS/git.apply

function modify_id(){
folder=$1
public_old=$2
public_new=$3
$ID_TO_NAME_TOOL $2 $1
$NAME_TO_ID_TOOL $3 $1
}

rm -rf $PORT_TEMP
mkdir $PORT_TEMP

$APKTOOL if -t xiaomi $XIAOMI_SYSTEM/framework/framework-res.apk
$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/framework/framework-res.apk -o $PORT_TEMP/framework-res_xiaomi

$APKTOOL if -t stock $STOCK_SYSTEM/framework/framework-res.apk
$APKTOOL d -t stock $STOCK_SYSTEM/framework/framework-res.apk -o  $PORT_TEMP/framework-res_stock

$APKTOOL d $XIAOMI_SYSTEM/framework/services.jar -o $PORT_TEMP/services.jar.out
modify_id $PORT_TEMP/services.jar.out $PORT_TEMP/framework-res_xiaomi/res/values/public.xml $PORT_TEMP/framework-res_stock/res/values/public.xml
mkdir -p $PORT_TEMP/overlay/services/smali/com/android/server
cp $PORT_TEMP/services.jar.out/smali/com/android/server/Tele* $PORT_TEMP/overlay/services/smali/com/android/server/

$APKTOOL d $XIAOMI_SYSTEM/framework/framework.jar -o $PORT_TEMP/framework.jar.out
modify_id $PORT_TEMP/framework.jar.out $PORT_TEMP/framework-res_xiaomi/res/values/public.xml $PORT_TEMP/framework-res_stock/res/values/public.xml
mkdir -p $PORT_TEMP/overlay/framework/smali/android/telephony
cp -r $PORT_TEMP/framework.jar.out/smali/android/telephony/* $PORT_TEMP/overlay/framework/smali/android/telephony

$APKTOOL d $XIAOMI_SYSTEM/framework/framework2.jar -o $PORT_TEMP/framework2.jar.out
modify_id $PORT_TEMP/framework2.jar.out $PORT_TEMP/framework-res_xiaomi/res/values/public.xml $PORT_TEMP/framework-res_stock/res/values/public.xml
mkdir -p $PORT_TEMP/overlay/framework2/smali/com/android/internal/telephony
cp -r $PORT_TEMP/framework2.jar.out/smali/com/android/internal/telephony/* $PORT_TEMP/overlay/framework2/smali/com/android/internal/telephony
mkdir -p $PORT_TEMP/overlay/framework2/smali/miui/telephony
cp -r $PORT_TEMP/framework2.jar.out/smali/miui/telephony/* $PORT_TEMP/overlay/framework2/smali/miui/telephony

$APKTOOL d $XIAOMI_SYSTEM/framework/telephony-common.jar -o $PORT_TEMP/telephony-common.jar.out
modify_id $PORT_TEMP/telephony-common.jar.out $PORT_TEMP/framework-res_xiaomi/res/values/public.xml $PORT_TEMP/framework-res_stock/res/values/public.xml
mkdir -p $PORT_TEMP/overlay/telephony-common/smali/
cp -r $PORT_TEMP/telephony-common.jar.out/smali/* $PORT_TEMP/overlay/telephony-common/smali/

$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/app/Stk.apk -o $PORT_TEMP/Stk
modify_id $PORT_TEMP/Stk/smali $PORT_TEMP/framework-res_xiaomi/res/values/public.xml $PORT_TEMP/framework-res_stock/res/values/public.xml
$APKTOOL b -t stock -a $PORT_TOOLS/aapt $PORT_TEMP/Stk -o $PORT_TEMP/Stk.apk

#unnecessary to change resouce id
#$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/app/TelephonyProvider.apk -o $PORT_TEMP/TelephonyProvider
#modify_id $PORT_TEMP/TelephonyProvider/smali $PORT_TEMP/framework-res_xiaomi/res/values/public.xml $PORT_TEMP/framework-res_stock/res/values/public.xml
#$APKTOOL b -t stock -a $PORT_TOOLS/aapt -t stock $PORT_TEMP/TelephonyProvider -o $PORT_TEMP/TelephonyProvider.apk

$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/priv-app/TeleService.apk -o $PORT_TEMP/TeleService
modify_id $PORT_TEMP/TeleService/smali $PORT_TEMP/framework-res_xiaomi/res/values/public.xml $PORT_TEMP/framework-res_stock/res/values/public.xml
#modify TeleService by wuxianlin start
$XMLMERGYTOOL TeleService/res/values $PORT_TEMP/TeleService/res/values
cd $PORT_TEMP
$GIT_APPLY $PORT_ROOT/TeleService/LTE.patch
cd $PORT_ROOT
#modify TeleService by wuxianlin end
$APKTOOL b -t stock -a $PORT_TOOLS/aapt $PORT_TEMP/TeleService -o $PORT_TEMP/TeleService.apk

