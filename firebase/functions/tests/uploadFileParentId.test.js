"use strict";
const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

// const assert = require("assert");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
    storageBucket: "withcenter-test-project.appspot.com",
  });
}

// get firestore
// const db = admin.firestore();

// This must come after initlization
const lib = require("../lib");

describe("updateFileParentId test", () => {
  it("no files", async () => {
    await lib.updateFileParentId("Pdcmt1sxVtLoVvq6AG7D", {
      title: "...",
      files: [
        "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads%2F525de0e1-7762-4c25-8bcc-bb361b565deb.jpg?alt=media&token=e7132bce-37e5-43d5-b63e-abcaac18e290",
        "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads%2F64b1f9be-f699-451f-b5f6-378a8b8999e7.jpg?alt=media&token=4b5bd88e-8dae-4e6b-a379-9e970b64541c",
      ],
    });
  });
});
