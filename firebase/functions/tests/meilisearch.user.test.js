"use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

// const assert = require("assert");
const admin = require("firebase-admin");
// const {MeiliSearch} = require("meilisearch");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}
// This must come after initlization
const lib = require("../lib");
const test = require("../test");

// TODO: User index (create, update, delete)
describe("Meilisearch test", () => {
  //   const client = new MeiliSearch({
  //     host: "http://wonderfulkorea.kr:7700",
  //   });

  // TODO ------ User test

  it("test index", async () => {
    const res = await lib.indexUserDocument("user-4-yo", {
      firstName: "three-yo-first-name",
      lastName: "Song",
    });
    if (res.status == 202) {
      // assert ok
    }
    console.log("something; ", res.status, res.statusText, res);
  });

  //   it("tests user create indexing", async () => {
  //     const ref = await test.createTestUser("user-b-2");
  //     console.log((await ref.get()).val());
  //   });
});
