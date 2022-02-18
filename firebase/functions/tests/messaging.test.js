"use strict";


const assert = require("assert");

const functions = require("firebase-functions");
const admin = require("firebase-admin");

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

// get firestore
const db = admin.firestore();   

describe("Messaging ~~~~~~~~~~~~~~~~", () => {


    it("get comment anscestor uid", async() => {
        const parent = await lib.createComment({
            category: {
                id: 'test'
            },
            post: {
                id: 'Pid-1',
                title: 'post_title',
                uid: 'A',
            },
            comment: {
                id: 'Cid-1',
                postId: 'Pid-1',
                parentId: 'Pid-1',
                content: 'comment_content',
                uid: 'B',
            }
        });
        

        await lib.createComment({
            comment: {
                id: 'Cid-2',
                postId: 'Pid-1',
                parentId: 'Cid-1',
                content: 'comment_content',
                uid: 'B',
            }
        });

        let res = await lib.getCommentAncestors('Cid-2', 'C');

        assert.ok( res.length == 1 && res[0] == 'B' );

        // expect ok. res.length == 1
        // Add a comment with same author uid.
        await lib.createComment({
            comment: {
                id: 'Cid-3',
                postId: 'Pid-1',
                parentId: 'Cid-2',
                uid: 'C',
            }
        });
        res = await lib.getCommentAncestors('Cid-3', 'C');
        assert.ok( res.length == 1 && res[0] == 'B' );


        // expect ok. res.length == 1.
        // Add a comment with different author, but still result is 1 since the current
        // comment is excluded.
        await lib.createComment({
            comment: {
                id: 'Cid-4',
                postId: 'Pid-1',
                parentId: 'Cid-3',
                uid: 'D',
            }
        });
        res = await lib.getCommentAncestors('Cid-4', 'C');
        assert.ok( res.length == 1 && res[0] == 'B' );

        // expect ok. res.length == 2.
        // Add a comment with different author
        await lib.createComment({
            comment: {
                id: 'Cid-5',
                postId: 'Pid-1',
                parentId: 'Cid-4',
                uid: 'E',
            }
        });
        res = await lib.getCommentAncestors('Cid-5', 'C');
        assert.ok( res.length == 2 && res[0] == 'D' && res[1] == 'B' );

    });

    // need to provide 2 valid tokens
    // create UserA and UserB
    // set UserA  user settings to subscribe to get notified if new comment is 
    // created under user post or comment
    // it creates 1000 fake tokens
    // create post for userA
    // userB comment to userA post
    // functions onCommentCreate send push notification and remove invalid tokens
    // userA should only have 2 token(valid) after onCreate
    it("Sending messages of 1002 tokens", async() => {
        const userA = 'userA';
        const userB = 'userB';
        await lib.createTestUser(userA);
        await admin.database().ref('user-settings').child(userA).child('topic').set({
            newCommentUnderMyPostOrCOmment: true,
          })
          
        await admin.database().ref('user-settings').child(userB).child('topic').set({
            newCommentUnderMyPostOrCOmment: false,
          })
        await lib.createTestUser(userB);
        const validToken1 = 'eiG6CUPQS66swAIEOakM60:APA91bGj4tjLswDzSAWz72onE_Tv50TYrI2I3hRXu-0RDJOa2c71elDDnL5gfrcZY5PfppRgbl2hC_R2A4SzstPu___yR9DzB1YoIDnJ-IITVxoqIJ_2gBLQOl9MGJ7_vRFZNmUfIVHD';
        const validToken2 = 'ecw_jCq6TV273wlDMeaQRY:APA91bF8GUuxtjlpBf7xI9M4dv6MD74rb40tpDedeoJ9w1TYi-9TmGCrt862Qcrj4nQifRBrxS60AiBSQW8ynYQFVj9Hkrd3p-w9UyDscLncNdwdZNXpqRgBR-LmSeZIcNBejvxjtfW4';
        
        const tokenUpdates = [];
        // set first valid token
        tokenUpdates.push( db.collection('message-tokens').doc(validToken1).set({uid: userA}));
        // set 1000 not valid token
        for( let i = 0; i < 1000; i ++ ) {
            tokenUpdates.push( db.collection('message-tokens').doc('userA-wrong-token-id-' + i).set({uid: userA}));
        }
        // set 2nd valid token
        tokenUpdates.push( db.collection('message-tokens').doc(validToken2).set({uid: userA}));
        await Promise.all(tokenUpdates);
        
        const before = await db.collection('message-tokens').where('uid', '==', userA).get();
        assert.ok( before.size ==  1002, 'should be 1002, got ' + before.size);
        
        //userA create parent post
        const postTestId = 'postTestId';
        await lib.createPost({
            category: { id: 'test' },
            post: {
                title: userA + 'messaging test title',
                content: 'yo',
                uid: userA,
                id: postTestId,
            },
        });

        const timestamp = (new Date).getTime();
        // userB create comment under userA post
        const commentTest1Id = 'commentTest1Id';
        await lib.createComment({
            comment: {
                id: commentTest1Id + timestamp,
                postId: postTestId,
                parentId: postTestId,
                content: commentTest1Id + timestamp +' comment_content',
                uid: userB,
            }
        });

        await lib.delay(18000);
        const after = await db.collection('message-tokens').where('uid', '==', userA).get();
        assert.ok( after.size == 2, 'should only have 2 left, got: ' + after.size);

        const UserBtokenUpdates = [];
        // set 5 fake token
        for( let i = 0; i < 5; i ++ ) {
            UserBtokenUpdates.push( db.collection('message-tokens').doc('userB-wrong-token-id-' + i).set({uid: userB}));
        }
        await Promise.all(UserBtokenUpdates);

        const commentTest2Id = 'commentTest2Id';
        await lib.createComment({
            comment: {
                id: commentTest2Id + timestamp,
                postId: postTestId,
                parentId: commentTest1Id + timestamp,
                content: commentTest2Id + timestamp +' comment_content by userA',
                uid: userA,
            }
        });

        await lib.delay(10000);
        const userBTokenCount = await db.collection('message-tokens').where('uid', '==', userB).get();
        assert.ok( userBTokenCount.size == 5, 'must have 5 tokens, got: ' + userBTokenCount.size);
        await admin.database().ref('user-settings').child(userB).child('topic').set({
            newCommentUnderMyPostOrCOmment: true,
          })

        const commentTest3Id = 'commentTest3Id';
        await lib.createComment({
            comment: {
                id: commentTest3Id + timestamp,
                postId: postTestId,
                parentId: commentTest2Id + timestamp,
                content: commentTest3Id + timestamp +' comment_content again by userA',
                uid: userA,
            }
        });

        await lib.delay(10000);
        const userBTokenCount2 = await db.collection('message-tokens').where('uid', '==', userB).get();
        assert.ok( userBTokenCount2.size == 0, 'must have 0 token by this time, got: ' + userBTokenCount2.size);
    });


    it("Filtering uids with topic and forum subscriber", async() => {
        const userA = 'subscriberTestUserA';
        const userB = 'subscriberTestUserB';
        const userC = 'subscriberTestUserC';
        const userD = 'subscriberTestUserD';
        const topic = 'subscriberTopicTest';
        await lib.createTestUser(userA);
        await lib.createTestUser(userB);
        await lib.createTestUser(userC);
        await lib.createTestUser(userD);
        await admin.database().ref('user-settings').child(userA).child('topic').set({
            newCommentUnderMyPostOrCOmment: true,
        })
        await admin.database().ref('user-settings').child(userB).child('topic').set({
            newCommentUnderMyPostOrCOmment: true,
            [topic]: true
        })
        await admin.database().ref('user-settings').child(userC).child('topic').set({
            newCommentUnderMyPostOrCOmment: false,
            [topic]: true
        })
        await admin.database().ref('user-settings').child(userD).child('topic').set({
            newCommentUnderMyPostOrCOmment: true,
            [topic]: false
        })

        const setTokens = [];
        setTokens.push( db.collection('message-tokens').doc(userA + '-wrong-token-id-').set({uid: userA}));
        setTokens.push( db.collection('message-tokens').doc(userB + '-wrong-token-id-').set({uid: userB}));
        setTokens.push( db.collection('message-tokens').doc(userC + '-wrong-token-id-').set({uid: userC}));
        setTokens.push( db.collection('message-tokens').doc(userD + '-wrong-token-id-').set({uid: userD}));
        await Promise.all(setTokens);

        const usersUid = [userA,userB,userC,userD];

        
        // remove subcriber uid but want to get notification under their post/comment
        let res = await lib.removeTopicAndForumAncestorsSubscriber(usersUid, topic);
        assert.ok( res.length == 2, 'userA and userD must get notified');
        assert.ok( res.includes(userA) && res.includes(userD));

        await admin.database().ref('user-settings').child(userC).child('topic').set({
            newCommentUnderMyPostOrCOmment: true,
            [topic]: false
        })
        res = await lib.removeTopicAndForumAncestorsSubscriber(usersUid, topic);
        assert.ok( res.length == 3, 'userA and userD must get notified and userC this time');
        assert.ok( res.includes(userA) && res.includes(userD) && res.includes(userC));

    });


  });


