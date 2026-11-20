# คู่มืออัปเดตข้อมูล Portfolio

แก้ไขข้อมูลได้เฉพาะในโฟลเดอร์ `assets/my_content/` โดยไม่ต้องแก้โค้ด UI ใน `lib/`

## ข้อมูลส่วนตัว

แก้ชื่อ ภาษาไทย/อังกฤษ อายุ อีเมล Bio และรูปโปรไฟล์ใน `profile/profile.json`

- `names.en` ถูกใช้สร้างชื่อไฟล์ Resume PDF เสมอ
- `birthDate` ใช้รูปแบบ `YYYY-MM-DD`; อายุจะคำนวณอัตโนมัติ
- `profileImage` ระบุ path รูปที่อยู่ใน `assets/my_content/images/profile/`

## การศึกษาและประสบการณ์

เพิ่มรายการใน `education` หรือ `experience` ของ `profile/profile.json`

- `period`: ช่วงเวลา
- `institution` / `organization`: สถาบันหรือองค์กร
- `field` / `role`: สาขาหรือบทบาท
- `details`: รายละเอียด

ทั้งไทยและอังกฤษต้องใส่เป็น `th` และ `en`

## ทักษะ ภาษาที่ใช้ และรูป

- กลุ่มทักษะอยู่ใน `skillGroups`
- ภาษาที่ใช้อยู่ใน `languages`
- วางรูป Profile ใน `images/profile/`
- วางรูปโปรเจกต์ใน `images/projects/`
- รูปฟอนต์วางใน `fonts/` และห้ามเปลี่ยนชื่อไฟล์ Sarabun ที่ประกาศใน `pubspec.yaml`

## เพิ่มหรือแก้ผลงาน

แก้รายการใน `projects/projects.json`

- ระบุ `id` ที่ไม่ซ้ำ
- ใส่ `title`, `category`, `summary`, `description`, `highlights` เป็นไทยและอังกฤษ
- ใส่ไฟล์รูปหลายไฟล์ใน `images`
- ตั้ง `featured: true` เพื่อแสดงใน Resume PDF

## ลิงก์

แก้ลิงก์ติดต่อและโซเชียลใน `links/links.json`

- `socialLinks`: GitHub, LinkedIn, Facebook และช่องทางอื่น
- `projectLinks`: ใช้ `projectId` ให้ตรงกับ `id` ใน `projects.json`
- ประเภทลิงก์รองรับ `github`, `demo`, `docs`, `video`, `other`

## ตรวจสอบหลังแก้ไข

```bash
flutter pub get
flutter analyze
flutter build web --release
flutter run -d chrome
```
