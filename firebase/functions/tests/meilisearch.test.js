"use strict";


const assert = require("assert");
 
const functions = require("firebase-functions");
const admin = require("firebase-admin");


const { MeiliSearch } = require('meilisearch')

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



describe("Meilisearch test", () => {
    const timestamp = (new Date).getTime();
    console.log('timestamp; ', timestamp)
    it('indexing test', async () => {
        await lib.createPost({
            category: {
                id: 'search-test'
            },
            post: {
                id: 'search-test-id-1',
                title: 'search-test-title ' + timestamp,
            }
        });
        await lib.delay(2000);

        const client = new MeiliSearch({
            host: 'http://wonderfulkorea.kr:7700',
        });

        
        const search = await client.index('posts').search('search-test-title')
        console.log(search);
        assert.ok( search.hits.length > 0 );
    });
});


