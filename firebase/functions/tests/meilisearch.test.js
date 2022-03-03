"use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;


const assert = require("assert");
const admin = require("firebase-admin");
const {MeiliSearch} = require("meilisearch");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}
// This must come after initlization
const lib = require("../lib");
const test = require("../test");

// TODO: User index (create, update, delete)
describe("Meilisearch test", () => {
  const timestamp = (new Date).getTime();
  console.log("timestamp; ", timestamp);

  const client = new MeiliSearch({
    host: "http://wonderfulkorea.kr:7700",
  });

  // Post test data.
  const categoryData = {id: "index-test"};
  const originalPostTitle = "post-" + timestamp;
  const newPostTitle = originalPostTitle + " ...(2)";
  const postData = {
    id: "index-post-" + timestamp,
    title: originalPostTitle,
  };

  // Comment test data.
  const originalCommentContent = "comment-" + timestamp;
  const newCommentContent = originalCommentContent + " ... (2)";
  const commentData = {
    id: "index-comment-" + timestamp,
    postId: postData.id,
    parentId: postData.id,
    content: originalCommentContent,
  };

  // User test data.
  const userId = 'user_aaa';
  const originalFirstName = 'User A'
  const newFirstName = 'User A (Updated)'
  const userData = {
    id: userId,
    firstName: originalFirstName,
    lastName: 'Lastname A',
  }

  // ------ Prep

  it("prepares test", async () => {
    const postFilters = await client
        .index("posts")
        .getFilterableAttributes();

    console.log("Post filterables: ", postFilters);
    if (!postFilters.includes("id")) {
      postFilters.push("id");
      console.log("Updating post filterables: ", postFilters);
      await client
          .index("posts")
          .updateFilterableAttributes(postFilters);
    }

    const commentFilters = await client
        .index("comments")
        .getFilterableAttributes();

    console.log("Comment filterables: ", commentFilters);
    if (!commentFilters.includes("id")) {
      commentFilters.push("id");
      console.log("Updating comment filterables: ", commentFilters);
      await client
          .index("comments")
          .updateFilterableAttributes(commentFilters);
    }

    const userFilters = await client
        .index("users")
        .getFilterableAttributes();

    console.log("User filterables: ", userFilters);
    if (!userFilters.includes("id")) {
      userFilters.push("id");
      console.log("Updating user filterables: ", userFilters);
      await client
          .index("users")
          .updateFilterableAttributes(userFilters);
    }
  });

  // ------ Post test

  it("tests post create indexing", async () => {
    await test.createPost({
      category: categoryData,
      post: postData,
    });
    await lib.delay(4000);

    const search = await client
        .index("posts")
        .search("", {filter: ["id = " + postData.id]});

    assert.ok( search.hits.length > 0 );
    assert.ok( search.hits[0].title == postData.title );
  });

  it("tests post update indexing", async () => {
    postData.title = newPostTitle;
    await test.createPost({
      category: categoryData,
      post: postData,
    });

    await lib.delay(4000);
    const search = await client
        .index("posts")
        .search("", {filter: ["id = " + postData.id]});
    assert.ok( search.hits.length > 0 );
    assert.ok( search.hits[0].title == postData.title );
  });

  it("tests post delete indexing", async () => {
    postData.title = "";
    postData.deleted = true;
    await test.createPost({
      category: categoryData,
      post: postData,
    });

    await lib.delay(4000);
    const search = await client
        .index("posts")
        .search("", {filter: ["id = " + postData.id]});

    assert.ok( search.hits.length == 0 );
  });


  // ------ Comment test

  it("tests comment create indexing", async () => {
    await test.createComment({
      comment: commentData,
    });

    await lib.delay(4000);
    const search = await client
        .index("comments")
        .search("", {filter: ["id = " + commentData.id]});

    assert.ok( search.hits.length > 0 );
    assert.ok( search.hits[0].content == commentData.content );
  });

  it("tests comment update indexing", async () => {
    commentData.content = newCommentContent;
    await test.createComment({
      comment: commentData,
    });

    await lib.delay(4000);
    const search = await client
        .index("comments")
        .search("", {filter: ["id = " + commentData.id]});

    assert.ok( search.hits.length > 0 );
    assert.ok( search.hits[0].content == commentData.content );
  });

  it("tests comment delete indexing", async () => {
    commentData.content = "";
    commentData.deleted = true;
    await test.createComment({
      comment: commentData,
    });

    await lib.delay(4000);
    const search = await client
        .index("comments")
        .search("", {filter: ["id = " + commentData.id]});

    assert.ok( search.hits.length == 0 );
  });

  
  // ------ User test

  // it("tests user create indexing", async () => {
  //   await test.createTestUser();

  //   await lib.delay(4000);
  //   const search = await client
  //       .index("comments")
  //       .search("", {filter: ["id = " + commentData.id]});

  //   assert.ok( search.hits.length > 0 );
  //   assert.ok( search.hits[0].content == commentData.content );
  // });
});


