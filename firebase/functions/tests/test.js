"use strict";


const assert = require("assert");
const admin = require("firebase-admin");

const { MeiliSearch } = require('meilisearch')

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



describe("Categories", () => {
    it("Get categories", async () => {
        const size = await lib.getSizeOfCategories();
        assert.ok( size > 0);
    });


    it("get comment anscestor uid", async() => {
        const parent = await lib.createComment({
            category: 'test',
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


    const timestamp = (new Date).getTime();
    it('Meilisearch', async () => {
        await lib.createPost({
            category: {
                id: 'search-test'
            },
            post: {
                id: 'Spid-1',
                title: 'search-test-title ' + timestamp,
            }
        });
        await lib.delay(2000);

        const client = new MeiliSearch({
            host: 'http://wonderfulkorea.kr:7700',
        });

        // 
        const search = await client.index('posts').search('search-test-title')
        console.log(search);

    });
});


