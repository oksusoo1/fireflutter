const firebase = require('@firebase/testing');
const { auth } = require('firebase');
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

async function setAdmin(uid) {
    return admin().collection("settings").doc("admins").set({
        [uid]: true,
    });
}

/// Create a category by admin
async function createCategory(id) {
    return admin().collection("categories").doc(id).set({
        title: id
    });
}

/// Create category by admin
async function createPost(category, docId, userUid, title) {
    return admin().collection("posts").doc(docId).set({
        category: category,
        authorUid: userUid,
        title: title,
        timestamp: 123,
    });
}

/// create a category and post
async function createCategoryPost(category, docId, userUid, title) {
    await createCategory(category);
    await createPost(category, docId, userUid, title);
}


/// Create a comment with userUid and random sample data.
/// ```
/// const doc = await createComment(A);
/// console.log((await doc.get()).data());
/// await firebase.assertFails(db(authC).doc(doc.path).delete());
/// ```
async function createComment(userUid) {
    await createCategoryPost('cat', 'doc', userUid, 'title');
    const doc = await db(authA).collection('posts').doc('doc').collection('comments').add({
        authorUid: userUid,
        timestamp: 123,
    });
    return doc;
}



/// 테스트 전에, 이전의 데이터를 모두 지운다.
beforeEach(async () => {
    await firebase.clearFirestoreData({ projectId: TEST_PROJECT_ID })
})

describe('Firestore security test', () => {

    it("notUpdating - method test", async () => {
        const doc = db().collection("test").doc("notUpdating").collection("col").doc("doc");
        await doc.set({ a: 'Apple', b: 'Banana', c: 'Cherry' });
        await firebase.assertFails(doc.update({ a: 'I like to eat apple' }));
        await firebase.assertFails(doc.update({ b: 'I like to eat banana' }));
        await firebase.assertSucceeds(doc.update({ c: 'I like to eat cherry' }));
        await firebase.assertFails(doc.update({ a: 1, b: 2, c: 3 }));
        await firebase.assertSucceeds(doc.update({ c: 3, d: 4, e: 5 }));
        await firebase.assertSucceeds(doc.update({}));
    });
    it("onlyUpdating - method test", async () => {
        const doc = db().collection("test").doc("onlyUpdating").collection("col").doc("doc");
        await doc.set({ a: 'Apple', b: 'Banana', c: 'Cherry' });
        await firebase.assertSucceeds(doc.update({ a: 'I like to eat apple' }));
        await firebase.assertSucceeds(doc.update({ b: 'I like to eat banana' }));
        await firebase.assertFails(doc.update({ c: 'I like to eat cherry' }));
        await firebase.assertFails(doc.update({ a: 1, b: 2, c: 3 }));
        await firebase.assertSucceeds(doc.update({ a: 1 }));
        await firebase.assertSucceeds(doc.update({ a: 1 }));
        await firebase.assertSucceeds(doc.update({}));
    });

    it("mustUpdating - method test", async () => {
        const doc = db().collection("test").doc("mustUpdating").collection("col").doc("doc");
        await doc.set({ a: 'Apple', b: 'Banana', c: 'Cherry' });

        // fail - a & b must be changed but remains the same value.
        await firebase.assertFails(doc.update({ a: 'Apple', b: 'Banana' }));

        // fail - must update a & b, but b didn't changed.
        await firebase.assertFails(doc.update({ a: 'change', c: 'change' }));

        // fail - must update a & b, but b didn't changed.
        await firebase.assertFails(doc.update({ a: 'change', b: 'Banana', c: 'change' }));

        // success - both of a & b changed
        await firebase.assertSucceeds(doc.update({ a: 'change', b: 'change', c: 'change' }));

    });

    it("fieldCheck - method test", async () => {
        const doc = db().collection("test").doc("fieldCheck").collection("col").doc("optionalOnly");
        await firebase.assertSucceeds(doc.set({ a: 'Apple', }));
        await firebase.assertSucceeds(doc.update({ b: 'Banana', c: 'Cherry' }));
        await firebase.assertFails(doc.update({ d: 'Dragon' }));


        const req = db().collection("test").doc("fieldCheck").collection("col").doc("requiredAndOptional");
        await firebase.assertFails(req.set({ a: 'Apple', }));
        await firebase.assertFails(req.set({ r: 1, a: 2, b: 2, c: 4, e: 5 }));
        await firebase.assertFails(req.set({ a: 1, b: 2, c: 3 }));
        await firebase.assertSucceeds(req.set({ r: 1, b: 2, c: 3 }));
    });




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

    it("Post fails - update by wrong auth", async () => {
        await createCategory('qna');
        await createPost('qna', 'docId', A, 'title');

        // Success - Wrong auth, but success because it does not change anything.
        await firebase.assertSucceeds(db(authB).collection('posts').doc('docId').update({
            title: 'title',
        }));

        // Fail - Wrong auth and try to change title
        await firebase.assertFails(db(authB).collection('posts').doc('docId').update({
            title: 'oo',
        }));
    });

    it("Post update - by correct auth", async () => {
        await createCategory('qna');
        await createPost('qna', 'docId', A, 'title');


        // Success
        await firebase.assertSucceeds(db(authA).collection('posts').doc('docId').update({
            content: 'content',
            timestamp: 12,
        }));


        // Fail - must change something to trigger failure on missing timestamp
        await firebase.assertFails(db(authA).collection('posts').doc('docId').update({
            content: 'content change',
        }));

    });



    /// Post deletion is not allowed.
    it("Post delete", async () => {
        await admin().collection("categories").doc("qna").set({
            title: 'QnA'
        });
        await admin().collection("posts").doc("aaa").set({
            authorUid: A,
            title: 'update test'
        });

        // delete with correct auth
        await firebase.assertFails(db(authA).collection('posts').doc('aaa').delete());

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
        await firebase.assertFails(db(authA).collection('posts').doc('admin-test').delete());

    });


    it('Post - increase view counter', async () => {
        await createCategory('cat');
        await createPost('cat', 'docId', A, 'title');
        await firebase.assertSucceeds(db().collection('posts').doc('docId').update({
            viewCounter: 1
        }));
        await firebase.assertSucceeds(db().collection('posts').doc('docId').update({
            viewCounter: 1
        }));
    });


    it('Comment - create', async () => {
        await createCategoryPost('cat', 'doc', A, 'title');
        const col = db(authA).collection('posts').doc('doc').collection('comments');
        /// success
        await firebase.assertSucceeds(col.add({
            authorUid: A,
            timestamp: 123,
        }));
        /// missing timestamp
        await firebase.assertFails(col.add({
            authorUid: A,
        }));
        /// Wrong uid
        await firebase.assertFails(col.add({
            authorUid: B,
            timestamp: 123,
        }));
    });



    it('Comment - update', async () => {
        await createCategoryPost('cat', 'doc', A, 'title');
        const doc = await db(authA).collection('posts').doc('doc').collection('comments').add({
            authorUid: A,
            timestamp: 123,
        });

        // console.log((await doc.get()).data());

        // success
        await firebase.assertSucceeds(doc.update({
            timestamp: 456,
        }));

        // success - update nothing
        await firebase.assertSucceeds(doc.update({}));



        // fail - timestamp is missing
        await firebase.assertFails(doc.update({
            content: '...',
        }));

        // console.log(doc.path);
        const docB = db(authB).doc(doc.path);

        // fail - update with wrong auth
        await firebase.assertFails(docB.update({ timestamp: 789 }));
        // success - updating only like, dislike,
        await firebase.assertSucceeds(docB.update({ like: 1 }));
        await firebase.assertSucceeds(docB.update({ like: 0, dislike: 1 }));

    });


    /// Comment deletion is not allowed.
    it('Comment - delete', async () => {
        const doc = await createComment(A);
        // console.log((await doc.get()).data());

        // fail - no auth
        await firebase.assertFails(db().doc(doc.path).delete());

        // fail - wrong auth
        await firebase.assertFails(db(authC).doc(doc.path).delete());

        // success - correct auth
        await firebase.assertFails(db(authA).doc(doc.path).delete());
    })



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


        // Fail - getting all docs from reports collection as a user
        await firebase.assertFails(db(authA).collection('reports').get());

        // Success - admin can get all report docs.
        await setAdmin(B);
        await firebase.assertSucceeds(db(authB).collection('reports').get());

    });
});


