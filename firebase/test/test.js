const firebase = require('@firebase/testing');
const TEST_PROJECT_ID = "withcenter-test-project";
const A = "user_A";
const B = "user_B";
const aAuth = { uid: A, email: A + '@gmail.com' };
function db(auth = null) {
    return firebase.initializeTestApp({ projectId: TEST_PROJECT_ID, auth: auth }).firestore();
}
function admin() {
    return firebase.initializeAdminApp({ projectId: TEST_PROJECT_ID }).firestore();
}

describe('Firestore security test', () => {
    it('Users - write test', async () => {
        const testDoc = db(aAuth).collection('users').doc(A);
        await firebase.assertSucceeds(testDoc.set({ foo: 'bar' }));
    });
    it("Posts - read", async () => {
        const testDoc = db().collection('posts').where('visibility', '==', 'public');
        await firebase.assertSucceeds(testDoc.get());
    })
    it("Posts - read by aAuth", async () => {
        const testDoc = db(aAuth).collection('posts').where('authorId', '==', A);
        await firebase.assertSucceeds(testDoc.get());
    })
    it("Posts - can't read collection", async () => {
        const testCol = db(aAuth).collection('posts');
        await firebase.assertFails(testCol.get());
    })
});