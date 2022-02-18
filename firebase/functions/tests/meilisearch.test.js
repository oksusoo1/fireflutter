"use strict";


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

  const timestamp = (new Date).getTime();
  console.log("timestamp; ", timestamp);

  const client = new MeiliSearch({
    host: "http://wonderfulkorea.kr:7700",
  });

  it("post create index test", async () => {
    await lib.createPost({
      category: {
        id: "search-test",
      },
      post: {
        id: "index-search-" + timestamp,
        title: timestamp.toString(),
      },
    });
    await lib.delay(3000);

    const searchA = await client.index("posts").search(timestamp.toString());
    const searchB = await client.index("posts-and-comments").search(timestamp.toString());
    console.log("posts index search: ", searchA);
    console.log("posts and comments search: ", searchB);
    assert.ok( searchA.hits.length > 0 );
    assert.ok( searchB.hits.length > 0 );
  });

  it("post update index test", async () => {

    const categoryData = { id: "update-test" };
    const postData = {
        id: "index-update-" + timestamp,
        title: timestamp.toString(),
    }

    // Create post
    //
    var res = await lib.createPost({
        category: categoryData,
        post: postData,
      });

    // await lib.delay(3000);
    // var search = await client.index("posts").search(timestamp.toString());
    // assert.ok( search.hits.length > 0 );

    // Update post
    //
    const newTitle = postData.title + " (2)";
    postData.title = newTitle;
    res = await lib.createPost({
        category: categoryData,
        post: postData,
    });
    await lib.delay(4000);

    const searchA = await client.index("posts").search(timestamp.toString());
    const searchB = await client.index("posts-and-comments").search(timestamp.toString());
    assert.ok( searchA.hits.length > 0 );
    assert.ok( searchB.hits.length > 0 );

    // data should exist on both `posts` and `posts-and-comments` index documents
    const searchAIndex = searchA.hits.findIndex((data) =>  data['id'] == postData.id);
    const searchBIndex = searchB.hits.findIndex((data) =>  data['id'] == postData.id);
    assert.ok( searchAIndex != -1 );
    assert.ok( searchBIndex != -1 );
    assert.ok( searchA.hits[searchAIndex]['title'] === newTitle );
    assert.ok( searchB.hits[searchBIndex]['title'] === newTitle );
  });


//   it("comment create index test", async () => {

//     // todo
//     //
//     // create post
//     // create comment with post.id as `postId`
//     // assert comment is created under `comments` and `posts-and-comments` index documents
//     // update comment
//     // assert comment data is update under `comments` and `posts-and-comments` index documents
//     assert.ok( true );

//    })
});


