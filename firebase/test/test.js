const firebase = require('@firebase/testing');
const TEST_PROJECT_ID = "withcenter-test-project";
const A = "user_A";
const B = "user_B";
const C = "user_C";
const authA = { uid: A, email: A + '@gmail.com' };
const authB = { uid: B, email: B + '@gmail.com' };
const authC = { uid: C, email: C + '@gmail.com' };
function db(auth = null) {
    return firebase.initializeTestApp({ projectId: TEST_PROJECT_ID, auth: auth }).firestore();
}
function admin() {
    return firebase.initializeAdminApp({ projectId: TEST_PROJECT_ID }).firestore();
}

/// 테스트 전에, 이전의 데이터를 모두 지운다.
beforeEach(async () => {
    await firebase.clearFirestoreData({ projectId: TEST_PROJECT_ID })
})

describe('Firestore security test', () => {

    it("User - read", async () => {
        const read = db().collection("users").doc("any-uid");
        await firebase.assertSucceeds(read.get());
    });
    it("User - write", async () => {
        const read = db().collection("users").doc("any-uid");
        await firebase.assertFails(read.set({ foo: "bar" }));

        const write = db(authA).collection("users").doc(A);
        await firebase.assertSucceeds(write.set({ foo: "bar" }));
    });

    it("Chat - message - read - failure test", async () => {

        /// expect fail, no auth
        const _noAuth = db().collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id');
        await firebase.assertFails(_noAuth.get());


        /// expect fail, wrong auth
        const _wrongAuth = db(authC).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id');
        await firebase.assertFails(_wrongAuth.get());

    });

    it("Chat - message - read - success teset", async () => {
        /// expect success, right auth A
        const _rigthA = db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id');
        await firebase.assertSucceeds(_rigthA.get());

        /// expect success, right auth B
        const _rigthB = db(authB).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id');
        await firebase.assertSucceeds(_rigthB.get());
    })


    it("Chat - message - write - failure test", async () => {

        /// expect fail, no auth
        const _noAuth = db().collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id');
        await firebase.assertFails(_noAuth.set({ to: B, from: A, text: 'yo', timestamp: 1 }));


        /// expect fail, wrong auth
        const _wrongAuth = db(authC).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id');
        await firebase.assertFails(_wrongAuth.set({ to: B, from: A, text: 'yo', timestamp: 1 }));

    });

    it("Chat - message - write - failure - 'to & from'", async () => {
        /// expect fails, due to wrong 'to', 'from'
        const _missing = db(authC).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id-a');
        await firebase.assertFails(_missing.set({ to: B, from: A, text: 'yo', timestamp: 1 }));

        const _wrong = db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id-a');
        await firebase.assertFails(_wrong.set({ to: B, from: C, text: 'yo', timestamp: 1 }));

        const _missingB = db(authB).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id-a');
        await firebase.assertFails(_missingB.set({ to: A, from: C, text: 'yo', timestamp: 1 }));
    })

    it("Chat - message - write - success", async () => {
        const right = db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('right');
        await firebase.assertSucceeds(right.set({ to: B, from: A, text: 'yo', timestamp: 1 }));
    });

    it("Chat - message - delete", async () => {
        await db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('right').set({
            to: B, from: A, text: 'yo', timestamp: 1,
        });
        // Fail - wrong user
        await firebase.assertFails(
            db(authC).collection("chat").doc("messages").collection(`${A}-${B}`).doc('right').delete()
        );
        // Fail - wrong user
        await firebase.assertFails(
            db(authB).collection("chat").doc("messages").collection(`${A}-${B}`).doc('right').delete()
        );
        // Success
        await firebase.assertSucceeds(
            db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('right').delete()
        );
    });

    it("Chat - block - read", async () => {

        /// failure, no auth
        const _noAuth = db().collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertFails(_noAuth.get());

        /// failure, wrong user
        const _wrongAuth = db(authC).collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertFails(_wrongAuth.get());

        /// success
        const _authA = db(authA).collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertSucceeds(_authA.get());

        const _authB = db(authB).collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertSucceeds(_authB.get());
    })

    it("Chat - block - write", async () => {

        /// failure, no auth
        const _noAuth = db().collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertFails(_noAuth.set({ timestamp: 1 }));

        /// failure, wrong user
        const _wrongAuth = db(authC).collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertFails(_wrongAuth.set({ timestamp: 1 }));

        /// failture, writable ONLY to the blocker. Not blockee.
        const _authB = db(authB).collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertFails(_authB.set({ timestamp: 1 }));

        /// success
        const _authA = db(authA).collection("chat").doc("blocks").collection(A).doc(B);
        await firebase.assertSucceeds(_authA.set({ timestamp: 1 }));

    })

    it("Chat - message - block user and test", async () => {
        await admin().collection("chat").doc("blocks").collection(A).doc(B).set({ timestamp: 1 });

        /// failure, blocked between A & B
        const blockedA = db(authA).collection("chat").doc("messages").collection(A + '-' + B).doc("any-id");
        await firebase.assertFails(blockedA.set({ from: A, to: B, text: 'yo', timestamp: 1 }))
        const blockedB = db(authA).collection("chat").doc("messages").collection(A + '-' + B).doc("any-id");
        await firebase.assertFails(blockedB.set({ from: B, to: A, text: 'yo', timestamp: 1 }))

        const blockedBA = db(authA).collection("chat").doc("messages").collection(B + '-' + A).doc("any-id");
        await firebase.assertFails(blockedBA.set({ from: B, to: A, text: 'yo', timestamp: 1 }))

        /// success, not blocked between A & C
        const blockedAC = db(authA).collection("chat").doc("messages").collection(A + '-' + C).doc("doc-id-ac");
        await firebase.assertSucceeds(blockedAC.set({ from: A, to: C, text: 'yo', timestamp: 1 }))

        /// success, not blocked between B & C
        const blockedBC = db(authB).collection("chat").doc("messages").collection(C + '-' + B).doc("doc-id-bc");
        await firebase.assertSucceeds(blockedBC.set({ from: B, to: C, text: 'yo', timestamp: 1 }))

    });


    it("Admin - reminder write test", async () => {
        await admin().collection("settings").doc("admins").set({
            [B]: true,
            [C]: true
        });


        await firebase.assertFails(db(authA).collection("settings").doc("reminder").set({ title: "hi" }))
        await firebase.assertSucceeds(db(authB).collection("settings").doc("reminder").set({ title: "hi" }))
        await firebase.assertSucceeds(db(authC).collection("settings").doc("reminder").set({ title: "hi" }))
    });




    it("Category - failure - Not admin", async () => {
        await firebase.assertFails(db(authA).collection('categories').doc('qna').set({ title: 'qna' }))
    });

    it("Category - success - admin", async () => {
        await admin().collection("settings").doc("admins").set({
            [A]: true,
        });
        await firebase.assertFails(db(authB).collection('categories').doc('qna').set({ title: 'qna' }))
        await firebase.assertSucceeds(db(authA).collection('categories').doc('qna').set({ title: 'qna' }))
    });


    it("Category - success", async () => {
        await admin().collection("settings").doc("admins").set({
            [A]: true,
        });
        await firebase.assertSucceeds(db(authA).collection('categories').doc('qna').set({ anyField: 'any data' }));
    });


    it("Post create failure without category", async () => {
        await firebase.assertFails(db(authA).collection('posts').add({ category: 'qna' }))
    });




    it("Post create failure without sign-in", async () => {
        await admin().collection("categories").doc("qna").set({
            title: 'QnA'
        });
        await firebase.assertFails(db().collection('posts').add({ category: 'qna' }))
    });


    it("Post create failure - wrong input data - category is missing", async () => {
        await admin().collection("categories").doc("qna").set({
            title: 'QnA'
        });
        await firebase.assertFails(db(authA).collection('posts').add({
            authorUid: A,
            title: '...',
            content: 'content',
            timestamp: '1',
        }));
    });

    it("Post create success - input any data", async () => {
        await admin().collection("categories").doc("qna").set({
            title: 'QnA'
        });
        await firebase.assertSucceeds(db(authA).collection('posts').add({
            category: 'qna',
            authorUid: A,
            title: '...',
            content: 'content',
            timestamp: '1',
            anyField: 'anyData'
        }));
    });

    it("Post update - failure", async () => {
        await admin().collection("categories").doc("qna").set({
            title: 'QnA'
        });

        // update non-existing post
        await firebase.assertFails(db(authA).collection('posts').doc('non-existing-post').update({
            authorUid: A,
        }));

        await admin().collection("posts").doc("aaa").set({
            authorUid: A,
            title: 'update test'
        });

        // update with wrong auth
        await firebase.assertFails(db(authB).collection('posts').doc('aaa').update({
            timestamp: '123',
        }));

    });

    it("Post update - success", async () => {
        await admin().collection("categories").doc("qna").set({
            title: 'QnA'
        });
        await admin().collection("posts").doc("aaa").set({
            authorUid: A,
            title: 'update test'
        });
        // timestamp is missing
        await firebase.assertFails(db(authA).collection('posts').doc('aaa').update({
            authorUid: A,
        }));
        // It is okay that authorUid is missing.
        await firebase.assertSucceeds(db(authA).collection('posts').doc('aaa').update({
            timestamp: '123',
        }));
    });

    it("Post delete", async () => {
        await admin().collection("categories").doc("qna").set({
            title: 'QnA'
        });
        await admin().collection("posts").doc("aaa").set({
            authorUid: A,
            title: 'update test'
        });
        // delete with wrong auth
        await firebase.assertFails(db(authB).collection('posts').doc('aaa').delete());

        // delete with correct auth
        await firebase.assertSucceeds(db(authA).collection('posts').doc('aaa').delete());

        /// A post created by C
        await admin().collection("posts").doc("admin-test").set({
            authorUid: C,
            title: 'update test'
        });

        // Set user A to admin
        await admin().collection("settings").doc("admins").set({
            [A]: true,
        });

        // Delete post by admin
        await firebase.assertSucceeds(db(authA).collection('posts').doc('admin-test').delete());

    });

    it('Reports', async () => {
        // missing input data
        await firebase.assertFails(db(authB).collection('reports').doc('a').set({
            'timestamp': '123',
        }));

        // success
        await firebase.assertSucceeds(db(authA).collection('reports').doc('post-aaa-A').set({
            'target': 'post',
            'targetId': 'aaa',
            'reporterUid': A,
            'reporteeUid': B,
            'timestamp': '123',
        }));


        // fails - wrong uid
        await firebase.assertFails(db(authA).collection('reports').doc('post-aaa-wrong-uid').set({
            'target': 'post',
            'targetId': 'post-aaa',
            'reporterUid': B,
            'reporteeUid': C,
            'timestamp': '123',
        }));


        // fails - same target & targetId
        await firebase.assertFails(db(authA).collection('reports').doc('post-aaa-A').set({
            'target': 'post',
            'targetId': 'post-aaa',
            'reporterUid': A,
            'reporteeUid': B,
            'timestamp': '123',
        }));

        // fails on updating. update is not allowed.
        await firebase.assertFails(db(authA).collection('reports').doc('post-aaa-A').update({
            'target': '...',
        }));

        // fails on deletion. deletion is not allowed.
        await firebase.assertFails(db(authA).collection('reports').doc('post-aaa-A').delete());


    });
});
