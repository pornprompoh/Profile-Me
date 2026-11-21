# คู่มือ Deploy Flutter Web บน Vercel

คู่มือนี้อ้างอิงการตั้งค่าจริงใน `.github/workflows/ci.yml`, `vercel.json` และ `scripts/vercel_build.sh` โดยใช้ Vercel เป็นแพลตฟอร์ม Production เพียงแห่งเดียว และไม่ใช้ GitHub Pages

## 1. ภาพรวมการ Deploy

```text
แก้โค้ดในเครื่อง
      |
      +--> Push / Pull Request ไปยัง GitHub (main หรือ dev)
      |        -> GitHub Actions: flutter pub get
      |        -> flutter analyze
      |        -> flutter build web --release
      |        -> รายงานผล CI (ผ่าน/ไม่ผ่าน) เท่านั้น
      |
      +--> Vercel เชื่อม Repository และ Build จาก commit เดียวกัน
               -> scripts/vercel_build.sh (Flutter 3.44.4)
               -> build/web
               -> Preview สำหรับ branch อื่น / Production เมื่อเข้า main
```

GitHub Actions ไม่มี Job หรือ Permission สำหรับ Deploy ไป GitHub Pages เว็บ Production อยู่บน Vercel เท่านั้น การ Push ไป `dev` จะเป็น Preview Deployment ตามการตั้งค่า Git ของ Vercel ส่วน `main` เป็น Production Branch ตามค่าที่แนะนำด้านล่าง

## 2. Git Workflow และ CI Check

ตรวจสอบ remote, branch และไฟล์ที่จะส่งก่อน:

```bash
git remote -v
git branch --show-current
git status
```

Repository นี้ใช้ remote `origin` ชี้ไปที่ `pornprompoh/Profile-Me` และ branch หลักบน GitHub คือ `main`; branch พัฒนาปัจจุบันคือ `dev` ตัวอย่างส่งการเปลี่ยนแปลงจาก `dev`:

```bash
git add <ไฟล์ที่ต้องการส่ง>
git commit -m "Describe the change"
git push origin dev
```

จากนั้นเปิดแท็บ **Actions** ของ `pornprompoh/Profile-Me` และเลือก Workflow **Flutter Web CI**:

- เครื่องหมายถูกสีเขียวหมายถึง `flutter pub get`, `flutter analyze` และ Production Web Build ผ่าน
- เครื่องหมายกากบาทสีแดงหมายถึงขั้นตอนใดขั้นตอนหนึ่งไม่ผ่าน ให้เปิด Run และดู Log ของ Step นั้น
- Workflow ทำงานเมื่อ Push หรือเปิด/อัปเดต Pull Request ที่มีเป้าหมายเป็น `main` หรือ `dev` และสั่งรันเองได้ด้วย **Run workflow**
- CI ตรวจและ Build เท่านั้น ไม่ Publish Artifact และไม่ Deploy ไป GitHub Pages

## 3. ตั้งค่าโปรเจกต์เดิมบน Vercel

ใช้ Vercel Project ที่เชื่อม Repository นี้อยู่แล้ว ไม่ต้องสร้าง Project ใหม่

1. เปิด Vercel Dashboard แล้วเลือก Project เดิม
2. ที่ **Settings > Git** ตรวจว่าเชื่อม Repository `pornprompoh/Profile-Me` และตั้ง **Production Branch** เป็น `main` หาก Push ไป `dev` จะได้ Preview Deployment
3. ที่ **Settings > General** ตรวจว่าเป็น Project เดิมของ Repository นี้
4. ที่ **Settings > Build and Deployment** ตั้งค่า **Root Directory** และช่อง Build ตามนี้:

   | ช่องตั้งค่า | ค่า |
   |---|---|
   | Framework Preset | `Other` |
   | Root Directory | `./` (Repository Root) |
   | Install Command | ใช้ค่า Default / ไม่ Override; ไม่มีขั้นติดตั้ง Node package |
   | Build Command | `bash scripts/vercel_build.sh` |
   | Output Directory | `build/web` |

   `Build Command` และ `Output Directory` ตรงกับ `vercel.json` สคริปต์จัดการ `flutter pub get` และ `flutter build web --release` เอง โดยล็อก Flutter ที่ `3.44.4` ให้ตรงกับ CI
5. **Environment Variables:** โปรเจกต์ปัจจุบันไม่ต้องใช้ Environment Variable เพื่อ Build หรือ Deploy จึงไม่ต้องเพิ่มค่าใด ๆ ห้ามใส่ Secret ลงใน Repository
6. หลังบันทึกการตั้งค่า ให้เปิด **Deployments** เลือก Deployment ล่าสุด กดเมนู `...` แล้วเลือก **Redeploy** หากต้องการล้าง Build Cache ให้ปิด/ยกเลิก **Use existing Build Cache** ก่อนยืนยัน Redeploy

`vercel.json` มี SPA Rewrite ไป `/index.html`, Security Headers และตั้ง Cache-Control ให้ HTML, Flutter Bootstrap/Service Worker และ Assets ตรวจเวอร์ชันใหม่ จึงไม่ควรเพิ่ม Rewrite ซ้ำใน Dashboard

## 4. เช็กลิสต์หลัง Deploy

เปิด Production URL ที่ Vercel แสดงให้ ทั้งบน Desktop และ Mobile:

- หน้าเว็บโหลดได้และฟอนต์ไทย Sarabun แสดงผลถูกต้อง
- แท็บเบราว์เซอร์แสดง Favicon แบบมุมโค้งมนใหม่ ไม่ติดแคช Flutter เดิม
- แบ่งแชร์ลิงก์แสดง `og:image` / `twitter:image` จากไอคอนแบรนด์เดียวกัน
- Navbar และ Mobile Drawer แสดงไอคอนสี่เหลี่ยมขอบมนหน้าชื่อ `Pornprom` ครบทั้ง Light/Dark และ 390px
- รูปใน Hero, About และ Projects โหลดครบ ไม่เป็นภาพเสีย
- สลับธีม Light/Dark แล้วสีและตัวอักษรยังอ่านได้
- สลับภาษาไทย/อังกฤษแล้วเนื้อหาเปลี่ยนครบ
- Smooth Scroll และ Scroll Spy เลือก Section ถูกต้อง
- ปุ่มคัดลอกอีเมลและเบอร์โทรใน Footer ทำงาน
- ปุ่ม Resume สร้าง/ดาวน์โหลด PDF ได้
- Refresh ที่ URL หรือเส้นทางภายในแอปแล้วไม่เจอ 404

## 5. ดูแลเนื้อหาและแก้ปัญหา

### อัปเดตข้อมูล

แก้ JSON หรือรูปที่เกี่ยวข้องใน `assets/my_content/` โดยคงชื่อ/โครงสร้างไฟล์ที่แอปรู้จัก จากนั้นตรวจ `git status`, เพิ่มเฉพาะไฟล์ที่ต้องการ, Commit และ Push ไป `dev` เพื่อดู CI และ Preview ก่อน เมื่อพร้อมแล้วให้ Merge Pull Request เข้า `main` เพื่อให้ Vercel สร้าง Production Deployment อัตโนมัติ

### ปัญหาที่พบบ่อย

| อาการ | วิธีตรวจและแก้ |
|---|---|
| Vercel Build Failed หรือ Dart SDK ไม่ตรง | ตรวจ Build Log ว่า Checkout ใช้ Flutter `3.44.4`; CI และ `scripts/vercel_build.sh` ล็อกเวอร์ชันเดียวกัน หากมีการเปลี่ยนเวอร์ชัน ต้องแก้ทั้งสองที่ให้ตรงกันและตรวจ `environment.sdk` ใน `pubspec.yaml` |
| หน้าเว็บขาว หรือ Assets โหลดไม่ขึ้น | เปิด Browser DevTools > Network ดูไฟล์ที่ตอบ 404; ตรวจว่า **Output Directory** เป็น `build/web`, Root Directory เป็น `./`, Build ผ่าน และ `pubspec.yaml` ประกาศ Asset นั้นไว้ จากนั้น Redeploy โดยไม่ใช้ Build Cache |
| JSON/รูปที่แก้แล้วยังเป็นข้อมูลเก่า | ตรวจว่า Commit/Deployment ล่าสุดมีไฟล์นั้น จากนั้น Hard Reload หรือเปิด Private Window; ถ้ายังเก่าให้ Redeploy โดยปิด **Use existing Build Cache** ค่า Cache-Control ของ `/assets/` บังคับให้ตรวจสอบไฟล์ใหม่ |
| Refresh หน้าแล้วได้ 404 | ตรวจว่า Deployment ใช้ `vercel.json` ใน Repository Root และยังมี Rewrite `/(.*)` ไป `/index.html`; ตรวจ Root Directory แล้ว Redeploy |
| CI ไม่เริ่มทำงาน | ตรวจว่า Push ไป `main` หรือ `dev` หรือ Pull Request มีเป้าหมายเป็น branch ดังกล่าว แล้วตรวจแท็บ **Actions** ว่า Workflow เปิดใช้งานอยู่ |

หาก Run CI หรือ Vercel Build ล้มเหลว ให้แก้ตาม Log และ Push commit ใหม่ ไม่จำเป็นต้องเปิด GitHub Pages
