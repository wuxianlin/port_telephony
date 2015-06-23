#!/bin/bash

PORT_ROOT=$(cd `dirname $0`; pwd)
PORT_TOOLS=$PORT_ROOT/tools

APKTOOL=$PORT_TOOLS/apktool

NAME_TO_ID_TOOL=$PORT_TOOLS/nametoid
ID_TO_NAME_TOOL=$PORT_TOOLS/idtoname

XIAOMI_SYSTEM=$PORT_ROOT/xiaomi/system
STOCK_SYSTEM=$PORT_ROOT/stockrom/system

XMLMERGYTOOL=$PORT_TOOLS/ResValuesModify/jar/ResValuesModify
GIT_APPLY=$PORT_TOOLS/git.apply

function modify_id
{
folder=$1
public_old=$2
public_new=$3
$ID_TO_NAME_TOOL $2 $1
$NAME_TO_ID_TOOL $3 $1
}

rm -rf port_tmp
mkdir port_tmp
$APKTOOL if -t xiaomi $XIAOMI_SYSTEM/framework/framework-res.apk
$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/framework/framework-res.apk -o port_tmp/framework-res_xiaomi
$APKTOOL if -t stock $STOCK_SYSTEM/framework/framework-res.apk
$APKTOOL d -t stock $STOCK_SYSTEM/framework/framework-res.apk -o  port_tmp/framework-res_stock

$APKTOOL d $XIAOMI_SYSTEM/framework/services.jar -o port_tmp/services.jar.out
modify_id port_tmp/services.jar.out port_tmp/framework-res_xiaomi/res/values/public.xml port_tmp/framework-res_stock/res/values/public.xml
mkdir -p port_tmp/overlay/services/smali/com/android/server
cp port_tmp/services.jar.out/smali/com/android/server/Tele* port_tmp/overlay/services/smali/com/android/server/

$APKTOOL d $XIAOMI_SYSTEM/framework/framework.jar -o port_tmp/framework.jar.out
modify_id port_tmp/framework.jar.out port_tmp/framework-res_xiaomi/res/values/public.xml port_tmp/framework-res_stock/res/values/public.xml
mkdir -p port_tmp/overlay/framework/android/telephony
cp -r port_tmp/framework.jar.out/smali/android/telephony/* port_tmp/overlay/framework/android/telephony

$APKTOOL d $XIAOMI_SYSTEM/framework/framework2.jar -o port_tmp/framework2.jar.out
modify_id port_tmp/framework2.jar.out port_tmp/framework-res_xiaomi/res/values/public.xml port_tmp/framework-res_stock/res/values/public.xml
mkdir -p port_tmp/overlay/framework2/com/android/internal/telephony
cp -r port_tmp/framework2.jar.out/smali/com/android/internal/telephony/* port_tmp/overlay/framework2/com/android/internal/telephony
mkdir -p port_tmp/overlay/framework2/miui/telephony
cp -r port_tmp/framework2.jar.out/smali/miui/telephony/* port_tmp/overlay/framework2/miui/telephony

$APKTOOL d $XIAOMI_SYSTEM/framework/telephony-common.jar -o port_tmp/telephony-common.jar.out
modify_id port_tmp/telephony-common.jar.out port_tmp/framework-res_xiaomi/res/values/public.xml port_tmp/framework-res_stock/res/values/public.xml
$APKTOOL b port_tmp/telephony-common.jar.out -o port_tmp/telephony-common.jar

$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/app/Stk.apk -o port_tmp/Stk
modify_id port_tmp/Stk/smali port_tmp/framework-res_xiaomi/res/values/public.xml port_tmp/framework-res_stock/res/values/public.xml
$APKTOOL b -t stock -a $PORT_TOOLS/aapt -t stock port_tmp/Stk -o port_tmp/Stk.apk

$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/app/TelephonyProvider.apk -o port_tmp/TelephonyProvider
modify_id port_tmp/TelephonyProvider/smali port_tmp/framework-res_xiaomi/res/values/public.xml port_tmp/framework-res_stock/res/values/public.xml
$APKTOOL b -t stock -a $PORT_TOOLS/aapt -t stock port_tmp/TelephonyProvider -o port_tmp/TelephonyProvider.apk

$APKTOOL d -t xiaomi $XIAOMI_SYSTEM/priv-app/TeleService.apk -o port_tmp/TeleService
modify_id port_tmp/TeleService/smali port_tmp/framework-res_xiaomi/res/values/public.xml port_tmp/framework-res_stock/res/values/public.xml
#modify TeleService by wuxianlin start
$XMLMERGYTOOL TeleService/res/values port_tmp/TeleService/res/values
cd port_tmp
$GIT_APPLY $PORT_ROOT/TeleService/LTE.patch
cd $PORT_ROOT
#modify TeleService by wuxianlin end
$APKTOOL b -t stock -a $PORT_TOOLS/aapt -t stock port_tmp/TeleService -o port_tmp/TeleService.apk


