"use strict";


const Axios = require("axios");
const assert = require("assert");
const admin = require("firebase-admin");

const {MeiliSearch} = require("meilisearch");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/',
  });
}
// This must come after initlization
const lib = require("../lib");

describe("Meilisearch test", () => {
    it("Backup a post", async () => {
        await Axios.post(
            "http://local.wonderfulkorea.kr/index.php?action=api/posts/record",
            _data
          );
    });
});
