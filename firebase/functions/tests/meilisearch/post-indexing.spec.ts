import "mocha";
import { expect } from "chai";
import { Test } from "../../src/classes/test";
import { Meilisearch } from "../../src/classes/meilisearch";
import { Utils } from "../../src/classes/utils";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

describe("Meilisearch post document indexing", () => {
  const timestamp = Utils.getTimestamp();
  const params = { id: "postId-" + timestamp };
  console.log("timestamp :", timestamp);

  it("prepares test", async () => {
    await Test.initMeiliSearchIndexFilter("posts", ["id"]);
  });

  // it("Test post create, update and delete indexing", async () => {
  //   const originalPost = {
  //     id: params.id,
  //     title: `${params.id} title`,
  //     category: "qna",
  //   };

  //   // Create.
  //   await Meilisearch.indexPostCreate(originalPost as any, { params: params } as any);
  //   await Utils.delay(3000);
  //   let searchResult = await Meilisearch.search("posts", { id: params.id });
  //   // console.log(searchResult);
  //   expect(searchResult.hits).has.length(1);

  //   // Update.
  //   const updatedPost = { ...originalPost, title: "post updated title" };
  //   Meilisearch.indexPostUpdate(
  //       {
  //         before: originalPost as any,
  //         after: updatedPost as any,
  //       },
  //     { params: params } as any
  //   );
  //   await Utils.delay(3000);
  //   searchResult = await Meilisearch.search("posts", { id: params.id });
  //   expect(searchResult.hits).has.length(1);
  //   expect(searchResult.hits[0].title === updatedPost.title).true;

  //   // Delete.
  //   // Expect index is deleted.
  //   await Meilisearch.deleteIndexedPostDocument({ params: params } as any);
  //   await Utils.delay(3000);
  //   searchResult = await Meilisearch.search("posts", { id: params.id });
  //   expect(searchResult.hits).has.length(0);
  // });

  // it("Test post ignore update when both title and content did not change.", async () => {
  //   const testPost = {
  //     title: "title-a",
  //     content: "a",
  //     category: "qna",
  //   } as any;

  //   await Meilisearch.indexPostUpdate(
  //       {
  //         before: testPost as any,
  //         after: { ...testPost, like: 3 } as any,
  //       },
  //     { params: params } as any
  //   );
  //   await Utils.delay(3000);

  //   let searchData = await Meilisearch.search("posts", { id: params.id });
  //   expect(searchData.hits.length).equals(0);

  //   await Meilisearch.indexPostUpdate(
  //       {
  //         before: { ...testPost, like: 3 } as any,
  //         after: { ...testPost, like: 4 } as any,
  //       },
  //     { params: params } as any
  //   );
  //   await Utils.delay(3000);

  //   searchData = await Meilisearch.search("posts", { id: params.id });
  //   expect(searchData.hits.length).equals(0);
  // });

  // it("Test create ignore for unknown categories.", async () => {
  //   const testPost = {
  //     id: params.id,
  //     title: `${params.id} title`,
  //   } as any;

  //   // no category (undefined)
  //   await Meilisearch.indexPostCreate(testPost as any, { params: params } as any);
  //   await Utils.delay(3000);
  //   let searchData = await Meilisearch.search("posts", { id: testPost.id });

  //   expect(searchData.hits.length).to.be.equals(0);

  //   // no category (empty string)
  //   testPost.category = "";
  //   await Meilisearch.indexPostCreate(testPost as any, { params: params } as any);
  //   await Utils.delay(3000);
  //   searchData = await Meilisearch.search("posts", { id: testPost.id });

  //   // category not in database
  //   testPost.category = "someCategory";
  //   await Meilisearch.indexPostCreate(testPost as any, { params: params } as any);
  //   await Utils.delay(3000);
  //   searchData = await Meilisearch.search("posts", { id: testPost.id });

  //   expect(searchData.hits.length).to.be.equals(0);

  //   // success
  //   testPost.category = "qna";
  //   await Meilisearch.indexPostCreate(testPost as any, { params: params } as any);
  //   await Utils.delay(3000);
  //   searchData = await Meilisearch.search("posts", { id: testPost.id });

  //   expect(searchData.hits.length).to.be.equals(1);

  //   Meilisearch.deleteIndexedPostDocument({ params: params } as any);
  // });

  it("Test update ignore for unknown categories.", async () => {
    const testPost: {
      id: string;
      title: string;
      category?: string;
    } = {
      id: params.id,
      title: `${params.id} title`,
    };

    // no category (undefined)
    await Meilisearch.indexPostUpdate(
        {
          before: {} as any,
          after: testPost as any,
        },
      { params: params } as any
    );
    await Utils.delay(3000);
    let searchData = await Meilisearch.search("posts", { id: testPost.id });

    expect(searchData.hits.length).to.be.equals(0);

    // no category (empty string)
    testPost.category = "";
    await Meilisearch.indexPostUpdate(
      {
        before: {} as any,
        after: testPost as any,
      } as any,
      { params: params } as any
    );
    await Utils.delay(3000);
    searchData = await Meilisearch.search("posts", { id: testPost.id });

    // category not in database
    testPost.category = "someCategory";
    await Meilisearch.indexPostUpdate(
      {
        before: {} as any,
        after: testPost as any,
      } as any,
      { params: params } as any
    );
    await Utils.delay(3000);
    searchData = await Meilisearch.search("posts", { id: testPost.id });

    expect(searchData.hits.length).to.be.equals(0);

    // success
    testPost.category = "qna";
    await Meilisearch.indexPostUpdate(
      {
        before: {} as any,
        after: testPost as any,
      } as any,
      { params: params } as any
    );
    await Utils.delay(3000);
    searchData = await Meilisearch.search("posts", { id: testPost.id });

    expect(searchData.hits.length).to.be.equals(1);

    Meilisearch.deleteIndexedPostDocument({ params: params } as any);
  });
});

