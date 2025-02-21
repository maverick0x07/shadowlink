## موارد مورد نیاز
### کامپیوتر با 2 اینترنت:
کامپیوتر با سیستم عامل ویندوز که همزمان به 2  "اینترنت استارلینک" و "اینترنت ایران" دسترسی داره

مثال: "اینترنت استارلینک" رو بصورت کابل LAN و "اینترنت ایران" رو بصورت Wi-Fi به کامپیوتر متصل میکنیم:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/nic.png)

### سرور ایران:
یک سرور ایران با سیستم عامل لینوکس (ترجیها Debian یا Ubuntu) که ازش به عنوان یک پل ارتباطی بین استارلینک و کاربر عمل میکنه

#### نکته:
در زمان خرید حتی ارزونترین سرور هم برای این پروژه جوابگو هستش و نیازی به خرید سرور گرون قیمت نیست!

## آموزش راه اندازی: سرور

ابتدا با استفاده از ssh به سرور متصل میشیم و پروژه رو دانلود میکنیم:

```bash
git clone https://github.com/maverick0x07/shadowlink.git
```

نکته: اگه اینترنت سرور قطع بود یا به هر دلیلی نتونستید فایل پروژه رو دانلود کنید، باید بصورت دستی فایل پروژه رو تو سرور آپلود کنید.

حالا وارد فولدر server پروژه میشیم و اسکریپت رو اجرا میکنیم:
```bash
cd shadowlink/server && chmod +x shadowlink.sh && ./shadowlink.sh
```

#### نکته: برای اجرای دستورات بالا احتیاج به دسترسی root داریم:
```bash
sudo su
```

#### منو اصلی:
![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/server_menu.png)

بعد از انتخاب گزینه اول یعنی "Setup" فقط در چند ثانیه سرور ما راه اندازی میشه:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/server_setup.png)

#### 1: اصلاعات پنل مدیریت کاربر
#### 2: توکن UUID که باید به بخش Client تحویل داده بشه

### نکته خیلی مهم:
برای افزایش امنیت، حتما اطلاعات پنل شامل یوزرنیم، پسورد، آدرس پورت و مسیر web رو از تنظیمات پنل تغییر بدید!

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/panel_auth.png)

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/panel_url.png)

## آموزش راه اندازی: کلاینت
بعد از اتصال دو اینترنت "استارلینک" و "ایران"، پروژه رو روی کامپیوتر دانلود کرده، وارد فولدر client میشیم و فایل shadowlink.bat رو اجرا میکنیم:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/client_script.png)

بعد از اجرا شدن، برنامه لیست کارت شبکه های موجود در کامپیوتر رو نمایش میده و در مرحله اول از ما میخواد که کارت شبکه ای که برای "اینترنت استارلینک" هست رو انتخاب کنیم (در این مثال کارت شبکه "اینترنت استارلینک" من گزینه 1 هستش):

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/client_starlink_nic.png)

در مرحله دوم باید کارت شبکه ای که برای "اینترنت ایران" هستش رو از لیست انتخاب کنید (در این مثال کارت شبکه "اینترنت ایران" من گزینه 10 هستش):

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/client_iran_nic.png)

حالا آدرس IP سرور ایران رو وارد میکنیم:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/client_bridge_ip.png)

و در آخر توکن UUID که تو اسکریپت اول نمایش داده شده بود رو وارد میکنیم:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/client_uuid.png)

با وارد کردن موارد خواسته شده، تانل شما بین کامپیوتر و سرور برقرار میشه:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/client_tunnel.png)

## آموزش راه اندازی: ساخت اکانت
با برقرار شدن تانل، کافیه وارد پنل مدیریت کاربری شده و اکانت با تنظیمات دلخواهتون بسازید:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/panel_client1.png)

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/panel_client2.png)

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/panel_client3.png)

و تمام! حالا کافیه لینک یا QR Code اکانت ساخته شده رو برای شخصی که میخواید ارسال کنید:

![App Screenshot](https://raw.githubusercontent.com/maverick0x07/shadowlink/refs/heads/main/pics/panel_client4.png)

#### نکته: پیشنهاد میشه از پروتکل "shadowsocks" با رمزنگاری "CHACHA20_IETF_POLY1305" استفاده کنید تا بتونید از نرم افزار Outline برای اتصال راحت تر تو تمام پلتفرم ها متصل بشید

برای ریست یا حذف پنل و تانل روی سرور ایران، کافیه مجددا فایل ```shadowlink.sh``` اجرا کرده و گزینه "Reset" یا "Uninstall" رو انتخاب کنید
