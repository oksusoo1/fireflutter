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
    fs.writeFileSync("backup.json", JSON.stringify(data));
  });
