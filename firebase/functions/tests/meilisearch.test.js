"use strict";


const assert = require("assert");
const admin = require("firebase-admin");

const {MeiliSearch} = require("meilisearch");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}
// This must come after initlization
const lib = require("../lib");


describe("Meilisearch test", () => {

  const timestamp = (new Date).getTime();
  console.log("timestamp; ", timestamp);

  const client = new MeiliSearch({
    host: "http://wonderfulkorea.kr:7700",
  });

//   it("indexing test", async () => {
//     await lib.createPost({
//       category: {
//         id: "search-test",
//       },
//       post: {
//         id: "search-test-id-1",
//         title: "search-test-title " + timestamp,
//       },
//     });
//     await lib.delay(2000);

//     const search = await client.index("posts").search("search-test-title");
//     // console.log(search);
//     assert.ok( search.hits.length > 0 );
//   });

  it("update index test", async () => {

    const postData = {
        id: "index-update" + timestamp,
        title: "index-update Original",
    };

    /// Create post
    const res = await lib.createPost({
        category: {
          id: "update-test",
        },
        post: postData,
      });
    await lib.delay(2000);
    console.log("created post =>>>", res);
    
    /// Update post
    postData.title = "index-update Updated",
    res = await lib.createPost({
        category: {
            id: "update-test",
        },
        post: postData,
    });
    console.log("updated post =>>>", res);
    
    const search = await client.index("posts").search(postData.title);
    console.log("search result ===> ", search);
    assert.ok( search.hits.length > 0 );
  });
});


