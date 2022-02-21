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
    databaseURL: "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

// get firestore
const db = admin.firestore();

// This must come after initlization
const lib = require("../lib");

describe("Backup test", () => {
  it("Create a post in firestore", async () => {
    await lib.createPost({
      category: "qna",
      title: "title-qna",
      content: "content-qna",
    });
  });


  // it("Backup a post", async () => {
  //   const _data = {
  //     id: 'id',
  //     uid: 'uid',
  //     title: 'data.title',
  //     category: 'data.category',
  //     content: 'data.content',
  //     timestamp: 1,
  // };
  //      Axios.post(
  //         "http://local.wonderfulkorea.kr/index.php?action=api/posts/record",
  //         _data
  //       ).then((r) => console.log('r; ', r))
  //       .catch((e) => console.log('e;', e));
  // });


  // it("Create a post in firestore", async() => {
  //   // const re =
  //    await lib.indexPost("search-test",{
  //       category: 'test-category',
  //       uid: 'uid-9-up',
  //       title: 'title - 9-up',
  //       content: 'content - 9-up',
  //       // timestamp: ((new Date).getTime() / 1000),
  //     },
  //   );

  //   // console.log('re; ', (await re.get()).data());
  // })
});
