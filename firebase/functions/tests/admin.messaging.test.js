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

describe("Admin Messaging ~~~~~~~~~~~~~~~~", () => {


    it("Admin sending push notification.", async() => {
        assert.ok( res.length == 1 && res[0] == 'B' );

    });
    

  });


