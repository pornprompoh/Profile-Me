// แก้ไขข้อมูลเว็บไซต์ทั้งหมดได้จากไฟล์นี้ โดยไม่ต้องแก้ HTML หรือ JavaScript ส่วนแสดงผล
const myProfile = {
  // ข้อมูลพื้นฐานและข้อความที่ใช้กำหนดชื่อเว็บไซต์
  site: {
    title: "ป๋อ | แฟ้มสะสมผลงาน",
    description: "แฟ้มสะสมผลงานและข้อมูลแนะนำตัวของป๋อ",
    language: "th",
    skipToContent: "ข้ามไปยังเนื้อหาหลัก",
    footer: "แฟ้มสะสมผลงานส่วนบุคคล"
  },

  // ชื่อจริง ชื่อเล่น และรูปโปรไฟล์ (ใส่พาธรูป เช่น ./assets/images/profile.jpg หรือเว้นว่างเพื่อใช้ Placeholder)
  identity: {
    fullName: "นาย พรพรม สุขใจมิตร",
    nickname: "ป๋อ",
    role: "นักศึกษาและนักพัฒนาที่กำลังเรียนรู้",
    image: "",
    imageAlt: "รูปโปรไฟล์ของป๋อ"
  },

  // วันเกิดรูปแบบ YYYY-MM-DD ใช้คำนวณอายุอัตโนมัติ และแสดงปีปัจจุบันเป็น พ.ศ.
  personal: {
    birthDate: "2006-04-17"
  },

  // การศึกษาและข้อความแนะนำตัว
  about: {
    heading: "เกี่ยวกับฉัน",
    introduction: "สวัสดีครับ ผมป๋อ สนใจเรียนรู้เทคโนโลยีและลงมือทำผลงานใหม่ ๆ อยู่เสมอ",
    educationLabel: "การศึกษา",
    education: "ปัจจุบันกำลังศึกษาอยู่ที่ สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง",
    ageLabel: "อายุ",
    birthDateLabel: "วันเกิด",
    currentYearLabel: "ปีปัจจุบัน",
    ageUnavailable: "ไม่ได้ระบุ",
    interestsLabel: "สิ่งที่สนใจ",
    interests: ["การพัฒนาเว็บไซต์", "การออกแบบประสบการณ์ผู้ใช้", "การเรียนรู้เทคโนโลยีใหม่"]
  },

  // รายการเมนูนำทางและป้ายกำกับสำหรับปุ่มเมนูบนหน้าจอขนาดเล็ก
  navigation: {
    home: "หน้าแรก",
    about: "เกี่ยวกับฉัน",
    projects: "ผลงาน",
    contact: "ติดต่อ",
    openMenu: "เปิดเมนูนำทาง",
    closeMenu: "ปิดเมนูนำทาง"
  },

  // ข้อความในส่วนแนะนำตัวและปุ่ม
  hero: {
    greeting: "สวัสดีครับ ผม",
    introduction: "ยินดีต้อนรับสู่พื้นที่รวบรวมข้อมูลและผลงานของผม",
    primaryAction: "ดูผลงาน",
    secondaryAction: "ติดต่อฉัน"
  },

  // เพิ่ม ลบ หรือแก้ไขผลงานได้จาก Array นี้
  // githubUrl ใส่ลิงก์ GitHub ของผลงาน (เว้นว่างแล้วปุ่มจะไม่แสดง)
  // image ใส่พาธรูปใน ./assets/images/projects/ (เว้นว่างหรือหาไฟล์ไม่พบจะแสดง Placeholder)
  projects: {
    heading: "ผลงานตัวอย่าง",
    introduction: "ตัวอย่างพื้นที่สำหรับเพิ่มผลงานของคุณ",
    allCategoriesLabel: "ทั้งหมด",
    githubLabel: "ดูบน GitHub",
    imageOpenLabel: "เปิดภาพขยาย",
    emptyLabel: "ยังไม่มีผลงานในหมวดหมู่นี้",
    items: [
      {
        title: "เว็บไซต์แนะนำตัว",
        description: "ตัวอย่างเว็บไซต์ส่วนบุคคลที่รวบรวมข้อมูลและช่องทางติดต่อไว้ในที่เดียว",
        category: "เว็บไซต์",
        githubUrl: "",
        image: "./assets/images/projects/portfolio.svg"
      },
      {
        title: "แดชบอร์ดข้อมูล",
        description: "ตัวอย่างหน้าสรุปข้อมูลที่เน้นการอ่านง่ายและรองรับหน้าจอหลายขนาด",
        category: "ส่วนติดต่อผู้ใช้",
        githubUrl: "",
        image: "./assets/images/projects/dashboard.svg"
      },
      {
        title: "โปรเจกต์ทดลอง",
        description: "พื้นที่สำหรับบันทึกแนวคิดและผลงานชิ้นถัดไป",
        category: "ทดลอง",
        githubUrl: "",
        image: "./assets/images/projects/experiment.svg"
      }
    ]
  },

  // ช่องทางติดต่อ: เว้นช่องทางที่ไม่ต้องการแสดงเป็นค่าว่าง หรือลบรายการออกได้
  contact: {
    heading: "ติดต่อฉัน",
    introduction: "เลือกช่องทางที่สะดวกเพื่อพูดคุยหรือดูข้อมูลเพิ่มเติม",
    emailLabel: "อีเมล",
    email: "",
    phoneLabel: "โทรศัพท์",
    phone: "",
    socialLinks: [
      { label: "GitHub", url: "" },
      { label: "LinkedIn", url: "" }
    ]
  },

  // ข้อความสำหรับ Lightbox ของภาพผลงาน
  modal: {
    closeLabel: "ปิดภาพขยาย"
  }
};

export default myProfile;
