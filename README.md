
# Shadowlink
<div align="center">
  "Let shadows be your bridge to the stars"
</div>

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/shadowlink.png)

## توضیح کوتاه
این پروژه یک راه حل برای ارتباط با "استارلینک" در شرایط قطعی کامل اینترنت (حتی قطعی اینترنت دیتاسنتر ها) ارائه میده

والبته که در شرایط معمولی هم میتونید از راه دور به اینترنت آزاد "استارلینک" با هر اینترنت و در هر مکانی متصل بشید

## دیاگرام نحوه اتصال
![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/diagram.png)

## آموزش نصب
### نسخه وب:
https://github.com/maverick0x07/shadowlink/blob/main/setup.md
### نسخه PDF:
https://github.com/maverick0x07/shadowlink/blob/main/setup.pdf

## کمک به پروژه

BTC: ```bc1qyg9k62wqx0vp64dzg0lt4hpkgyartwc4paa0xp```

ETH: ```0x1712201C077Ea47b6B38E574498d16C88A3bDF5C```

TON: ```UQCZqSvVyxc-_Yz0lQ4ZOv-1BkcwhvRDyjJyzmCCE9d3fdrN```

USDT-TRC20: ```TYa8qPR2f4nFxke1tAzVzbQNTcuBGjr88R```
## نکات برای کاربران حرفه ای

### سرویس Systemd سرور

```shadowlink.service```

این سرویس مسئول اجرا تانل Xray-Core همینطور اجرا پنل 3x-ui هستش

### مسیر کانفیگ و دیتابیس سرور

File & Configs: ```/opt/shadowlink```

Panel Database: ```/etc/3x-ui/x-ui.db```

### تنظیم پورت
اتصال بین سرور و کلاینت بر روی پورت 7091 هستش که درصورت نیاز قابل تغییر هست. برای تغییر پورت میتونید تغییر دلخواه خودتون رو در فایل های ```sample_config.json``` برای کلاینت و ```tunnel_server.json.sample``` و ```3x-ui.json.sample``` برای سرور اعمال کنید. پورت پیشفرض پنل هم 7092 بوده که میتونید از تنظیمات پنل تغییر بدید

### تغییر نوع تانل
بصورت پیشفرض تانل بین کلاینت و سرور بصورت VLESS + TCP هستش که میتونید کانفیگ دلخواه خودتون رو در فایل های ```sample_config.json``` برای کلاینت و ```tunnel_server.json.sample``` و ```3x-ui.json.sample``` برای سرور اعمال کنید

### تغییر اطلاعات تانل کلاینت
اطلاعت وارد شده کلاینت همگی در فایل ```env``` ذخیره میشه که میتونید با تغییر اطلاعت و اجرای مجدد فایل تغییرات ایجاد شده رو اعمال کنید

### تغییر Route سرویس های ایرانی در پنل
در پنل، Route پیشفرض برای سرویس های ایرانی (دامنه ir و ip های ایرانی) بر روی خود سرور ایران ست شده. این موضوع برای جلوگیری از Leak شدن IP استارلینک هستش

### اضافه کردن VPN به مسیر
اگر نیاز به VPN برای پنهان کردن IP استارلینک برای سرویس های خارجی دارید باید اطلاعات VPN رو در سمت کلاینت و در فایل ```sample_config.json``` وارد کنید


#### نکته: اسکریپت کلاینت کاملا Dynamic بوده و حتی با تغییر NIC و یا IP، اطلاعت مجددا از کاربر دریافت میشه

#### نکته: در این پروژه سعی شده کمترین وابستگی به اینترنت وجود داشته باشه تا درصورت قطعی کامل اینترنت حتی در سمت سرور بازهم امکان برقراری ارتباط وجود داشته باشه

#### نکته: باتوجه به مشخص نبودن قطعی اینترنت، پیشنهاد میشه تمام این پروژه رو دانلود و در جای امنی نگه داری کنید
