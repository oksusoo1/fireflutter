const fei = require("firestore-export-import");
const fs = require("fs");

const serviceAccount = require("../firebase-admin-sdk-key.json");

fei.initializeFirebaseApp(serviceAccount);

fei
  .backups([
    "categories",
    "chat",
    "comments",
    "feeds",
    "posts",
    "quiz-history",
    "reports",
    "settings",
  ])
  .then((data) => {
    const d = new Date();
    const Ymd = d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
    fs.writeFileSync("backup-" + Ymd + ".json", JSON.stringify(data));
  });
