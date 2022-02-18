"use strict";


const assert = require("assert");
 
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
    const serviceAccount = require("../../withcenter-test-project.adminKey.json");
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
}
// This must come after initlization
const lib = require("../lib");

// get firestore
const db = admin.firestore();   

describe("Messaging", () => {


    // it("get comment anscestor uid", async() => {
    //     const parent = await lib.createComment({
    //         category: {
    //             id: 'test'
    //         },
    //         post: {
    //             id: 'Pid-1',
    //             title: 'post_title',
    //             uid: 'A',
    //         },
    //         comment: {
    //             id: 'Cid-1',
    //             postId: 'Pid-1',
    //             parentId: 'Pid-1',
    //             content: 'comment_content',
    //             uid: 'B',
    //         }
    //     });
        

    //     await lib.createComment({
    //         comment: {
    //             id: 'Cid-2',
    //             postId: 'Pid-1',
    //             parentId: 'Cid-1',
    //             content: 'comment_content',
    //             uid: 'B',
    //         }
    //     });

    //     let res = await lib.getCommentAncestors('Cid-2', 'C');

    //     assert.ok( res.length == 1 && res[0] == 'B' );

    //     // expect ok. res.length == 1
    //     // Add a comment with same author uid.
    //     await lib.createComment({
    //         comment: {
    //             id: 'Cid-3',
    //             postId: 'Pid-1',
    //             parentId: 'Cid-2',
    //             uid: 'C',
    //         }
    //     });
    //     res = await lib.getCommentAncestors('Cid-3', 'C');
    //     assert.ok( res.length == 1 && res[0] == 'B' );


    //     // expect ok. res.length == 1.
    //     // Add a comment with different author, but still result is 1 since the current
    //     // comment is excluded.
    //     await lib.createComment({
    //         comment: {
    //             id: 'Cid-4',
    //             postId: 'Pid-1',
    //             parentId: 'Cid-3',
    //             uid: 'D',
    //         }
    //     });
    //     res = await lib.getCommentAncestors('Cid-4', 'C');
    //     assert.ok( res.length == 1 && res[0] == 'B' );

    //     // expect ok. res.length == 2.
    //     // Add a comment with different author
    //     await lib.createComment({
    //         comment: {
    //             id: 'Cid-5',
    //             postId: 'Pid-1',
    //             parentId: 'Cid-4',
    //             uid: 'E',
    //         }
    //     });
    //     res = await lib.getCommentAncestors('Cid-5', 'C');
    //     assert.ok( res.length == 2 && res[0] == 'D' && res[1] == 'B' );

    // });


    it("Sending messages of 1001 tokens", async() => {
        // const user = await lib.createTestUser();
        console.log(user);
        // const tokens = [ ' .... correct tokens .... '];
        // const tokenUpdates = [];
        // for( i = 0; i < 1000; i ++ ) {
        //     tokenUpdates.push( db.collection('message-tokens').doc('wrong-token-' + i).set({uid: 'uid of user A'}));
        // }
        // tokenUpdates.push(' ... another correct tokens ... ');
        // await Promise.all(tokenUpdates);

        // await lib.createPost({
        //     category: { id: 'test' },
        //     post: {
        //         title: 'messaging test title',
        //         content: 'yo',
        //     }
        // });

        // await lib.delay(9000);

        // const snapshot = await db.collection('message-tokens').where('uid', '=', 'uid of user A').get();

        // assert.ok( snapshot.size == 2);
    });

});


