"use strict";


const assert = require("assert");
 
const functions = require("firebase-functions");
const admin = require("firebase-admin");

const lib = require("../lib");



// initialize the firebase
if (!admin.apps.length) {
    const serviceAccount = require("../../withcenter-test-project.adminKey.json");
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
}


// get firestore
const db = admin.firestore();   

async function createCategory(category) {
    return db.collection('categories').doc(category).set({title: 'create category'});
}
async function createPost(category) {
    return db.collection('posts').add({ category: category, title: 'create post'});
}

function createComment() {
    await createCategory('test');
    const ref = await createPost('test');
    return db.collection('comments').add({postId: ref.id, parentId: ref.id, content: 'create comment'});
}

describe("Categories", () => {
    it("Get categories", async () => {
        const snapshot = await db.collection("categories").get();
        const size = snapshot.size;
        console.log('size; ', size);
        assert.ok( size > 0);
    });
    it("Prepare data", async() => {
        await createComment();
    });
   });
   