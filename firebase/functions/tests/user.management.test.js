// "use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;


// const assert = require("assert");

// const functions = require("firebase-functions");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}
// This must come after initlization

const assert = require("assert");
const lib = require("../lib");
const test = require("../test");

// get firestore
const db = admin.firestore();


// get real time database
const rdb = admin.database();


describe("Admin user management ~~~~~~~~~~~~~~~~", () => {
  it("Admin block and unblock user.", async () => {
    const userA = "ddLo0QHMvhZBbG9v7zBU8WUod4o2";
    const userB = "k0QDjEXgWwSXsBe6zHVozxCYxp23";
    const userC = "lZ6YejW9bDZ1EBSZL2SQn1okTRz2";
    await test.createTestUser(userA);
    await test.createTestUser(userB);
    await test.createTestUser(userC);
    
    // set userA as admin
    await db.collection('settings').doc('admins').set({[userA]: true}, {merge: true});
    try {
        const re = await  lib.disableUser({uid: userB}, {});
        if ( re.code ==  'ERROR_YOU_ARE_NOT_ADMIN') assert.ok("should be error since user not provided");
        else assert.fail("must be error with ERROR_YOU_ARE_NOT_ADMIN, but got: " + re);
    } catch(e) {
        assert.fail("should be error with ERROR_YOU_ARE_NOT_ADMIN" + e);
    }

    try {
        const re = await  lib.disableUser({uid: userB}, {auth: {uid: userC }});
        if ( re.code ==  'ERROR_YOU_ARE_NOT_ADMIN') assert.ok("should be error since user is not admin");
        else assert.fail("must be error with ERROR_YOU_ARE_NOT_ADMIN, but got: " + re);
    } catch(e) {
        assert.fail("should be error with ERROR_YOU_ARE_NOT_ADMIN" + e);
    }

    try {
        const re = await  lib.disableUser({uid: userB}, {auth: {uid: userA}});
        const c = await  lib.disableUser({uid: userC}, {auth: {uid: userA}});
        assert.ok(re.uid == userB, "userB uid");
        assert.ok(re.disabled == true, "userB must be disabled true");
        assert.ok(c.disabled == true, "userC must be disabled true");
    } catch(e) {
        assert.fail("must be no error: " + e);
    }

    
    
    try {
        const res = await  rdb.ref('users').orderByChild('disabled').equalTo(true).get();
        assert.ok(res.exists(), 'users must exist with disable true');
        const users = res.val();
        assert.ok(users[userB].disabled == true, 'userB must exist with disable true');
        assert.ok(users[userC].disabled == true, 'userC must exist with disable true');
    } catch(e) {
        assert.fail("query must be no error: " + e);
    }


    try {
        const res = await rdb.ref('users').child(userB).get();
        const user = res.val();
        assert.ok(res.exists, 'user must exist');
        assert.ok(user.disabled == true, 'user marked as disabled')
    } catch(e) {
        assert.fail('user must exist and marked as disabled but got error: ' + e);
    }


    try {
        const b = await  lib.enableUser({uid: userB}, {auth: {uid: userA}});       
        const c = await  lib.enableUser({uid: userC}, {auth: {uid: userA}});
        assert.ok(b.uid == userB, "userB uid for enabling user");
        assert.ok(b.disabled == false, "userB must be disabled false");
        assert.ok(c.disabled == false, "userC must be disabled false");
    } catch(e) {
        assert.fail("must be no error: " + e);
    }

    try {
        const res = await  rdb.ref('users').orderByChild('disabled').equalTo(false).get();
        assert.ok(res.exists(), 'users must exist with disable true');
        const users = res.val();
        assert.ok(users[userB].disabled == false, 'userB must exist with disable false');
        assert.ok(users[userC].disabled == false, 'userC must exist with disable false');
    } catch(e) {
        assert.fail("query must be no error: " + e);
    }


    try {
        const res = await rdb.ref('users').child(userB).get();
        const user = res.val();
        assert.ok(user.disabled == false, 'user marked as disabled as false')
    } catch(e) {
        assert.fail('user disabled must be false but got error: ' + e);
    }


      
  });
});


