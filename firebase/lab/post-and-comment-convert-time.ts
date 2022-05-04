import * as admin from "firebase-admin";
import { FirebaseAppInitializer } from "./firebase-app-initializer";

new FirebaseAppInitializer();
const db = admin.firestore();

let count = 0;
db.collection("posts")
  .get()
  .then((snapshot) => {
    snapshot.forEach((doc) => {
      convertTime(doc);
      count++;
    });
  });
db.collection("comments")
  .get()
  .then((snapshot) => {
    snapshot.forEach((doc) => {
      convertTime(doc);
      count++;
    });
  });

async function convertTime(doc: admin.firestore.DocumentData) {
  const data = doc.data();
  if (data.createdAt && data.updatedAt && typeof data.createdAt === "object") {
    console.log(
      count,
      doc.id,
      "=>",
      data.createdAt._seconds,
      data.updatedAt._seconds,
      typeof data.createdAt
    );

    await doc.ref.update({
      createdAt: data.createdAt._seconds,
      updatedAt: data.updatedAt._seconds,
    });
  } else {
    console.log(doc.id, "=>", "No time data or already converted.");
  }
}
