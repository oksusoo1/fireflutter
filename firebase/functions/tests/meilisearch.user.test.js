"use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

const assert = require("assert");
const admin = require("firebase-admin");
const {MeiliSearch} = require("meilisearch");

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
const lib = require("../lib");
const test = require("../test");

// TODO: User index (create, update, delete)
describe("Meilisearch test", () => {
  const timestamp = new Date().getTime();
  console.log("timestamp; ", timestamp);

  const client = new MeiliSearch({
    host: "http://wonderfulkorea.kr:7700",
  });

  // User test data.
  const userId = "user_" + timestamp;
  const originalFirstName = "User " + timestamp;
  const newFirstName = originalFirstName + " (Update)";
  const userData = {
    id: userId,
    firstName: originalFirstName,
  };

  it("prepares filterables", async () => {
    const userFilters = await client.index("users").getFilterableAttributes();

    console.log("User filterables: ", userFilters);
    if (!userFilters.includes("id")) {
      userFilters.push("id");
      console.log("Updating user filterables: ", userFilters);
      await client.index("users").updateFilterableAttributes(userFilters);
    }
  });

  // User test

  it("test creating and deleting index functions", async () => {
    const res = await lib.indexUserDocument(userData.id, userData);
    await lib.delay(3000);
    // console.log("something; ", res.status, res.statusText, res);

    // It can pass, but data may still not be indexed on meilisearch.
    assert.ok(res.status == 202, "Status error: it should be 202 (Accepted)");

    let search = await client.index("users").search("", {filter: ["id = " + userData.id]});
    // console.log(search);

    assert.ok(search.hits.length > 0, "Search result must not be empty.");
    assert.ok(search.hits[0].id == userData.id, "Search result item must include test post.");

    await lib.deleteIndexedUserDocument(userData.id);
    await lib.delay(3000);

    search = await client.index("users").search("", {filter: ["id = " + userData.id]});

    assert.ok(search.hits.length == 0, "Search result must be empty.");
  });

  it("tests user create indexing", async () => {
    await test.createTestUser(userData.id, userData);
    await lib.delay(4000);

    const search = await client.index("users").search("", {filter: ["id = " + userData.id]});

    assert.ok(search.hits.length > 0, "Search result must not be empty.");
    assert.ok(search.hits[0].id == userData.id, "Search result item must include test post.");
  });

  it("tests user update indexing", async () => {
    userData.firstName = newFirstName;
    await test.createTestUser(userData.id, userData);
    await lib.delay(4000);

    const search = await client.index("users").search("", {filter: ["id = " + userData.id]});

    assert.ok(search.hits.length > 0, "Search result must not be empty.");
    assert.ok(search.hits[0].firstName == newFirstName, "User firstname must be updated");
  });

  it("tests user delete indexing", async () => {
    await test.deleteTestUser(userData.id);
    await lib.delay(4000);

    const search = await client.index("users").search("", {filter: ["id = " + userData.id]});

    assert.ok(search.hits.length == 0, "Search result must be empty.");
  });
});
