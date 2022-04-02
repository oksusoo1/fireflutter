import "mocha";
import { expect } from "chai";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";
import { Meilisearch } from "../../src/classes/meilisearch";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

describe("Meilisearch comment document indexing", () => {
  const timestamp = Utils.getTimestamp();
  const params = { id: "comment-" + timestamp };
  // console.log("timestamp :", timestamp);

  it("prepares test", async () => {
    await Test.initMeiliSearchIndexFilter("comments", ["id"]);
  });

  it("Tests comment create, update and delete indexing", async () => {
    // Create index
    const testComment = {
      id: params.id,
      uid: "test-uid-a",
      postId: "test-post-id-a",
      parentId: "test-parent-id-a",
      content: `${params.id} content`,
    };
    await Meilisearch.indexCommentCreate(testComment as any, { params: params } as any);
    await Utils.delay(3000);

    // Search if the post is indexed.
    // It should exactly contain 1 document, since it is filtered out.
    let searchResult = await Meilisearch.search("comments", { id: params.id });
    expect(searchResult.hits).has.length(1);

    // Update Index
    // Check if original and updated comment do not have same content.
    // Check if search result and updated comment have same content.
    const updatedComment = { ...testComment, title: "post updated title" };
    await Meilisearch.indexCommentUpdate(
        {
          before: testComment as any,
          after: updatedComment as any,
        },
      {
        params: params,
      } as any
    );
    await Utils.delay(3000);
    searchResult = await Meilisearch.search("comments", { id: params.id });
    expect(testComment).not.to.be.equals(updatedComment.content);
    expect(searchResult.hits[0].content).to.be.equals(updatedComment.content);

    // Deleting
    await Meilisearch.deleteIndexedCommentDocument({ params: params } as any);
    await Utils.delay(3000);

    // Search
    // It should not contain a document since it is should be deleted..
    searchResult = await Meilisearch.search("comments", { id: params.id });
    expect(searchResult.hits).has.length(0);
  });

  it("Tests comment update ignore", async () => {
    await Meilisearch.indexCommentUpdate(
        {
          before: { content: "12345" } as any,
          after: { content: "54321" } as any,
        },
      { params: params } as any
    );
    await Utils.delay(3000);

    const createdData = await Meilisearch.search("comments", { id: params.id });

    expect(createdData.hits.length).equals(1);

    await Meilisearch.indexCommentUpdate(
        {
          before: createdData as any,
          after: { ...createdData, like: 2 } as any,
        },
      { params: params } as any
    );
    await Utils.delay(3000);

    const updatedData = await Meilisearch.search("comments", { id: params.id });

    expect(createdData.hits[0].updatedAt).equal(updatedData.hits[0].updatedAt);

    await Meilisearch.indexCommentUpdate(
        {
          before: createdData as any,
          after: { content: "again .." } as any,
        },
      { params: params } as any
    );
    await Utils.delay(3000);

    const anotherUpdate = await Meilisearch.search("comments", { id: params.id });

    expect(createdData.hits[0].updatedAt).to.be.below(anotherUpdate.hits[0].updatedAt);

    // Cleanup.
    await Meilisearch.deleteIndexedCommentDocument({ params: params } as any);
  });
});

