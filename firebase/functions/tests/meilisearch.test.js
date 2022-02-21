"use strict";


const assert = require("assert");
const admin = require("firebase-admin");

const {MeiliSearch} = require("meilisearch");

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


describe("Meilisearch test", () => {

    const timestamp = (new Date).getTime();
    console.log("timestamp; ", timestamp);

    const client = new MeiliSearch({
        host: "http://wonderfulkorea.kr:7700",
    });

    /// Post test data.
    const categoryData = { id: "update-test" };
    const originalPostTitle = "post-" + timestamp;
    const newPostTitle = originalPostTitle + " ...(2)";
    const postData = {
        id: "index-post-" + timestamp,
        title: originalPostTitle,
    };

    /// Comment test data.
    const originalCommentContent = "comment-" + timestamp
    const newCommentContent = originalCommentContent + " ... (2)";
    const commentData = {
        id: "index-comment-" + timestamp,
        postId: "post-" + timestamp,
        parentId: "post-" + timestamp,
        content: originalCommentContent,
    };


    it("tests post create indexing", async () => {
        await lib.createPost({
            category: {
                id: "search-test",
            },
            post: postData,
        });
        await lib.delay(3000);


        
        const search = await client.index("posts").search('"' + originalPostTitle + '"');
        assert.ok( search.hits.length > 0 );

        const index = search.hits.findIndex((item) => item['id'] === postData.id);
        assert.ok( index != -1 );
    });

    it("tests post update indexing", async () => {
        postData.title = newPostTitle;
        await lib.createPost({
            category: categoryData,
            post: postData,
        });

        await lib.delay(3000);
        const search = await client.index("posts").search('"' + originalPostTitle + '"');
        assert.ok( search.hits.length > 0 );

        const newPostTitleIndex = search.hits.findIndex((item) => item['title'] === newPostTitle);
        const originalPostTitleIndex = search.hits.findIndex((item) => item['title'] === originalPostTitle);
        assert.ok( newPostTitleIndex != -1 );
        assert.ok( originalPostTitleIndex == -1 );
    });

    it("tests post delete indexing", async () => {
        postData.title = '';
        postData.deleted = true;
        await lib.createPost({
            category: categoryData,
            post: postData,
        });

        await lib.delay(3000);
        const search = await client.index("posts").search('"' + originalPostTitle + '"');
        assert.ok( search.hits.length == 0 );
    });

    it("tests comment create indexing", async () => {
        await lib.createComment({
            comment: commentData
        });

        await lib.delay(3000);
        const search = await client.index("comments").search('"' + originalCommentContent + '"');
        assert.ok( search.hits.length > 0 );
        
        // Find comment's ID on the returned list, to determine existence.
        // When searching the whole content there is a high probability that it's the first item on the list.
        // Expect that index is not equal to -1. Meaning the comment is indexed and searchable.
        const index = search.hits.findIndex((item) => item['id'] === commentData.id);
        assert.ok( index != -1 );
    })

    it("tests comment update indexing", async () => {
        commentData.content = newCommentContent;
        await lib.createComment({
            comment: commentData
        });

        await lib.delay(3000);
        var search = await client.index("comments").search('"' + originalCommentContent + '"');
        assert.ok( search.hits.length > 0 );

        /// Search for the original content.
        /// Comment with the updated content will be searched also since it partially contains the original content.
        ///
        /// Prove that the data is updated by:
        ///  - Checking if the new content is existing on the result list, and;
        ///  - the original content is not existing on the result list.
        const newCommentContentIndex = search.hits.findIndex((item) => item['content'] === newCommentContent);
        const originalCommentContentIndex = search.hits.findIndex((item) => item['content'] === originalCommentContent);
        assert.ok( newCommentContentIndex != -1 );
        assert.ok( originalCommentContentIndex == -1 );
    })

    it("tests comment delete indexing", async () => {
        commentData.content = '';
        commentData.deleted = true;
        await lib.createComment({
            comment: commentData
        });

        await lib.delay(3000);
        var search = await client.index("comments").search('"' + originalCommentContent + '"');
        assert.ok( search.hits.length == 0 );
    })
});


