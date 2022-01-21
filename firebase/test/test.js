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
        await firebase.assertFails(_noAuth.set({ foo: 'bar' }));


        /// expect fail, wrong auth
        const _wrongAuth = db(authC).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id');
        await firebase.assertFails(_wrongAuth.set({ foo: 'bar' }));

    });

    it("Chat - message - write - failure - 'to' and 'from'", async () => {
        /// expect fails, due to wrong 'to', 'from'
        const _missing = db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id-a');
        await firebase.assertFails(_missing.set({ foo: 'bar' }));

        const _wrong = db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id-a');
        await firebase.assertFails(_wrong.set({ to: 'foo', from: 'bar' }));

        const _missingB = db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('message-doc-id-a');
        await firebase.assertFails(_missingB.set({ to: A, from: 'bar' }));

    })


    it("Chat - message - write - success", async () => {
        const right = db(authA).collection("chat").doc("messages").collection(`${A}-${B}`).doc('right');
        await firebase.assertSucceeds(right.set({ to: A, from: B }));
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

    it("Chat - block - block user and test", async () => {
        await admin().collection("chat").doc("blocks").collection(A).doc(B).set({ timestamp: 1 });

        /// failure, blocked between A & B
        const blockedA = db(authA).collection("chat").doc("messages").collection(A + '-' + B).doc("any-id");
        await firebase.assertFails(blockedA.set({ from: A, to: B, text: 'yo' }))
        const blockedB = db(authA).collection("chat").doc("messages").collection(A + '-' + B).doc("any-id");
        await firebase.assertFails(blockedB.set({ from: B, to: A, text: 'yo' }))

        const blockedBA = db(authA).collection("chat").doc("messages").collection(B + '-' + A).doc("any-id");
        await firebase.assertFails(blockedBA.set({ from: B, to: A, text: 'yo' }))

        /// success, not blocked between A & C
        const blockedAC = db(authA).collection("chat").doc("messages").collection(A + '-' + C).doc("doc-id-ac");
        await firebase.assertSucceeds(blockedAC.set({ from: A, to: C, text: 'yo' }))

        /// success, not blocked between B & C
        const blockedBC = db(authB).collection("chat").doc("messages").collection(C + '-' + B).doc("doc-id-bc");
        await firebase.assertSucceeds(blockedBC.set({ from: B, to: C, text: 'yo' }))


    });



});