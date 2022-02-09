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
async function createPost(category, docId, userUid, title = 'title') {
    return admin().collection("posts").doc(docId).set({
        category: category,
        uid: userUid,
        title: title,
        timestamp: 123,
    });
}

/// create a category and post
async function createCategoryPost(category, docId, userUid, title = 'title') {
    await createCategory(category);
    return createPost(category, docId, userUid, title);
}




/// Create a comment.
/// the postId and parentId are set equal.
/// ```js
/// await firebase.assertSucceeds(createComment('cat', 'post-aaa', A));
/// ```
/// ```js
/// const doc = await createComment('cat', 'post-aaa', A);
/// console.log('comment create; data; ', (await doc.get()).data());
/// ```
/// ```js
/// const comment = await createComment('cat', 'post-1111', A);
/// await firebase.assertSucceeds(comment.update({
///     content: 'comment update',
///     timestamp: 87070880,
/// }));
/// ```
async function createComment(category, postId, userUid) {
    await createCategoryPost(category, postId, userUid, 'title');
    // console.log((await db().collection('posts').doc(postId).get()).data());
    // console.log('---- params; ', category, postId, parentId, userUid);
    const re = await db(authA).collection('comments').add({
        postId: postId,
        parentId: postId,
        uid: userUid,
        timestamp: 1,
    });
    // console.log('--- re ---');
    // console.log((await re.get()).data());
    return re;
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
            uid: A,
            title: '...',
            content: 'content',
            timestamp: '1',
        }));
    });

    it("Post create success - input any data", async () => {
        // await admin().collection("categories").doc("qna").set({
        //     title: 'QnA'
        // });
        await createCategory('qna');
        await firebase.assertSucceeds(db(authA).collection('posts').add({
            category: 'qna',
            uid: A,
            title: '...',
            content: 'content',
            timestamp: '1',
            anyField: 'anyData'
        }));
    });

    it("Post update - failure", async () => {
        await createCategory('qna');

        // update non-existing post
        await firebase.assertFails(db(authA).collection('posts').doc('non-existing-post').update({
            uid: A,
        }));

    });

    it("Post update - fail - wrong auth ", async () => {
        await createCategoryPost('qna', 'docId', A, 'title');

        // update with wrong auth
        await firebase.assertFails(db(authB).collection('posts').doc('docId').update({
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
            uid: A,
            title: 'update test'
        });

        // delete with correct auth
        await firebase.assertFails(db(authA).collection('posts').doc('aaa').delete());

        /// A post created by C
        await admin().collection("posts").doc("admin-test").set({
            uid: C,
            title: 'update test'
        });

        // Set user A to admin
        await admin().collection("settings").doc("admins").set({
            [A]: true,
        });

        // Delete post by admin - admin can't delete
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



    it('Comment - failure test', async () => {

        await createCategoryPost('cat', 'doc', A, 'title');
        const col = db(authA).collection('comments');
        await firebase.assertSucceeds(col.add({ parentId: 'doc', postId: 'doc', timestamp: 123, uid: A }));

        /// Missing properties
        await firebase.assertFails(col.add({
            postId: 'doc', timestamp: 123, uid: A
        }));
        await firebase.assertFails(col.add({
            parentId: 'doc', timestamp: 123, uid: A
        }));
        await firebase.assertFails(col.add({
            parentId: 'doc', postId: 'doc', uid: A
        }));
        await firebase.assertFails(col.add({
            parentId: 'doc', postId: 'doc', timestamp: 123
        }));


        /// Wrong auth
        await firebase.assertFails(col.add({
            parentId: 'doc', postId: 'doc', timestamp: 123, uid: B
        }));

    });


    it('Comment - create - same rootId & parentId', async () => {
        await createCategoryPost('cat', 'doc', A, 'title');
        const col = db(authA).collection('comments');
        await firebase.assertSucceeds(col.add({
            postId: 'doc',
            parentId: 'doc',
            uid: A,
            timestamp: 123,
        }));
    });

    it('Comment - create - "commentCreate" method', async () => {

        await firebase.assertSucceeds(createComment('cat', 'post-aaa', A));
    });

    it("Comment - create - parentId is paernt comment's id ", async () => {

        const commentDoc = await createComment('cat', 'post-aaa', A);

        await firebase.assertSucceeds(db(authA).collection('comments').add({
            postId: 'post-aaa',
            parentId: commentDoc.id,
            uid: A,
            timestamp: 123,
            content: 'c',
        }));

    });

    it("Comment - create - fail - wrong parentId", async () => {

        await createComment('cat', 'post-aaa', A);

        await firebase.assertFails(db(authA).collection('comments').add({
            postId: 'post-aaa',
            parentId: 'worng-pagent-id',
            uid: A,
            timestamp: 123,
            content: 'c',
        }));
    });



    it('Comment - update', async () => {
        const comment = await createComment('cat', 'post-1111', A);
        // console.log((await comment.get()).data());

        //
        await firebase.assertSucceeds(comment.update({
            timestamp: 2,
            content: 'c',
        }));


        // fails with wrong auth
        await firebase.assertFails(comment.update({
            uid: B,
            timestamp: 3,
            content: 'c',
        }));

    })




    it('Comment - update - timestamp & like', async () => {
        const comment = await createComment('cat', 'post-222', A);
        /// timestamp didn't changed. so, C11 fails
        /// But no properties changed. so, C12 succeeds.
        /// See comments in rules.
        await firebase.assertSucceeds(comment.update({
            timestamp: 1
        }));
        /// 
        /// timestamp didn't changed, so, C11 fails
        //. But only like, dislike chagned. so, C12 succeeds.
        await firebase.assertSucceeds(comment.update({
            timestamp: 1,
            like: 1,
            dislike: 2,
        }));

        await firebase.assertSucceeds(comment.update({
            dislike: 3
        }))

        /// properties changde but timestamp didn't changed. so, C11 fails.
        await firebase.assertFails(comment.update({
            content: 'c1',
            timestamp: 1,
        }));





    })



    /// Comment deletion is not allowed.
    it('Comment - delete', async () => {
        const doc = await createComment('cat', 'doc', A);
        // console.log((await doc.get()).data());

        // fail - no auth
        await firebase.assertFails(db().doc(doc.path).delete());

        // fail - wrong auth
        await firebase.assertFails(db(authC).doc(doc.path).delete());

        // success - correct auth
        await firebase.assertFails(db(authA).doc(doc.path).delete());
    })



    it('Reports - fail 1', async () => {
        // missing input data
        await firebase.assertFails(db(authB).collection('reports').doc('a').set({
            'timestamp': '123',
        }));
    });


    it("Resports - success", async () => {

        await createCategoryPost('cat', 'postId', A);

        // success
        await firebase.assertSucceeds(db(authB).collection('reports').add({
            'target': 'post',
            'targetId': 'postId',
            'reporterUid': B,
            'reporteeUid': A,
            'timestamp': 123,
        }));


    });

    it("Resports - fail - wrong post id", async () => {
        await createCategoryPost('cat', 'postId', A);
        // fail - wrong post id
        await firebase.assertFails(db(authB).collection('reports').add({
            'target': 'post',
            'targetId': 'wrong-id',
            'reporterUid': B,
            'reporteeUid': A,
            'timestamp': 123,
        }));
    });


    it("Resports - comments", async () => {

        const commentDoc = await createComment('cat', 'postId', A);

        // success
        await firebase.assertSucceeds(db(authB).collection('reports').add({
            'target': 'comment',
            'targetId': commentDoc.id,
            'reporterUid': B,
            'reporteeUid': A,
            'timestamp': 123,
        }));

        // fail - wrong id
        await firebase.assertFails(db(authB).collection('reports').add({
            'target': 'comment',
            'targetId': 'wrong id',
            'reporterUid': B,
            'reporteeUid': A,
            'timestamp': 123,
        }));
    });





    it("Resports - read", async () => {


        /// success - read by the creator

        await createCategoryPost('cat', 'postId', C);

        // success
        await firebase.assertSucceeds(db(authA).collection('reports').doc('r').set({
            'target': 'post',
            'targetId': 'postId',
            'reporterUid': A,
            'reporteeUid': C,
            'timestamp': 123,
        }));


        // success - right auth
        await firebase.assertSucceeds(db(authA).collection('reports').doc('r').get());

        // fail - wrong auth
        await firebase.assertFails(db(authB).collection('reports').doc('r').get());

        // fail - right auth, but can get all the documents.
        await firebase.assertFails(db(authA).collection('reports').get());

        // fail - wrong auth
        await firebase.assertFails(db(authB).collection('reports').get());


        // success - B is admin and can get all documents.
        await setAdmin(B);
        await firebase.assertSucceeds(db(authB).collection('reports').get());
        await firebase.assertSucceeds(db(authB).collection('reports').doc('r').get());

    });

    it("Messaging tokenUpdate", async () => {

        const doc = db().collection("message-tokens").doc("tokenA");

        // fail - field required is wrong must be uid only
        await firebase.assertFails(doc.set({ id: 'Apple'} , {merge:true}));

        // succes - field required is wrong must be uid only
        await firebase.assertSucceeds(doc.set({ uid: 'Apple'} , {merge:true}));
        
        // succes - data exist
        await firebase.assertSucceeds(doc.get());
    });

    it("Users subscribe topics", async () => {

        const doc = db().collection("message-tokens").doc("tokenA");

        // fail - field required is wrong must be uid only
        await firebase.assertFails(doc.set({ id: 'Apple'} , {merge:true}));

        // succes - field required is wrong must be uid only
        await firebase.assertSucceeds(doc.set({ uid: 'Apple'} , {merge:true}));
        
        // succes - data exist
        await firebase.assertSucceeds(doc.get());
    });

});


