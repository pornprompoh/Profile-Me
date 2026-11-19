# Profile-Me

เว็บไซต์แฟ้มสะสมผลงานแบบ Static ด้วย HTML, CSS และ Vanilla JavaScript ES Modules ไม่มี Framework หรือขั้นตอน Build

## โครงสร้าง

```text
.
├── index.html                         # โครงสร้าง Semantic เปล่าและจุดเชื่อม CSS/JavaScript
├── vercel.json                        # clean URLs, Security Headers และ Cache-Control
├── .gitignore                         # ไฟล์ที่ไม่ควรส่งขึ้น Git
├── assets/
│   └── images/projects/               # ภาพตัวอย่างผลงานแบบ SVG
├── css/
│   ├── base/                           # Design tokens, reset และ layout
│   ├── components/                     # ปุ่ม การ์ด Chips และ Lightbox
│   └── sections/                       # สไตล์ Navbar และแต่ละ Section
└── js/
    ├── data/myProfile.js               # จุดแก้ไขข้อมูลเว็บไซต์เพียงไฟล์เดียว
    ├── main.js                         # Entry point ตั้งค่า metadata และเรียกแต่ละโมดูล
    ├── modules/                        # ตัวแสดงผล Navbar, Hero, About, Projects, Contact
    └── utils/                          # ตัวช่วยคำนวณวันและสร้าง DOM
```

## แก้ไขข้อมูลและผลงาน

แก้ชื่อ ข้อมูลแนะนำตัว วันเกิด การศึกษา ข้อความ UI และช่องทางติดต่อใน `js/data/myProfile.js` เท่านั้น

เพิ่มผลงานโดยเพิ่ม object ใน `projects.items` แต่ละรายการรองรับ `title`, `description`, `category`, `githubUrl` และ `image`:

```js
{
  title: "ชื่อผลงาน",
  description: "คำอธิบายผลงาน",
  category: "หมวดหมู่",
  githubUrl: "https://github.com/ชื่อผู้ใช้/ชื่อโปรเจกต์",
  image: "./assets/images/projects/ชื่อภาพ.svg"
}
```

วางไฟล์ภาพไว้ใต้ `assets/images/projects/` หากไม่ระบุภาพหรือลิงก์ GitHub ระบบจะแสดง Placeholder หรือซ่อนปุ่มตามลำดับ ภาพผลงานที่ระบุสามารถคลิกหรือใช้คีย์บอร์ดเพื่อเปิด Lightbox ได้

## เพิ่มหรือลบ Section

Section แต่ละส่วนมี element ที่ระบุ `data-*` ใน `index.html` และโมดูลเฉพาะใน `js/modules/` โมดูลจะข้ามการทำงานเมื่อไม่พบ element ของ Section นั้น หากเพิ่ม Section ใหม่ ให้เพิ่มโครงสร้างเปล่าใน HTML, โมดูลและ CSS ของ Section แล้ว import และเรียกโมดูลจาก `js/main.js` ข้อความที่แสดงให้เพิ่มใน `myProfile.js` ห้ามใส่ข้อมูลส่วนตัวหรือข้อความแสดงผลไว้ใน HTML

## ทดลองในเครื่อง

เปิดโฟลเดอร์ด้วย static server ที่รองรับ ES Modules หรือใช้ Live Server ใน VS Code เนื่องจาก JavaScript modules มักถูกเบราว์เซอร์บล็อกเมื่อเปิด `index.html` ด้วย `file://`

## GitHub และ Vercel

```bash
git add .
git commit -m "Create data-driven portfolio website"
git push -u origin main
```

จากนั้นเข้า Vercel เลือก **Add New → Project**, Import repository จาก GitHub แล้วกด **Deploy** ได้เลย ไม่ต้องกำหนด Build Command หรือ Output Directory
