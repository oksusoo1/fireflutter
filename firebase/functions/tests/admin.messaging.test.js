// "use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

// const assert = require("assert");

// const functions = require("firebase-functions");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}
// This must come after initlization
// const lib = require("../lib");

// get firestore
// const db = admin.firestore();

describe("Admin Messaging ~~~~~~~~~~~~~~~~", () => {
  it("Admin sending push notification.", async () => {
    // assert.ok( res.length == 1 && res[0] == "B" );
  });
});
