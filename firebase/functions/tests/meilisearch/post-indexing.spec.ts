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
  // console.log("timestamp :", timestamp);

  it("prepares test", async () => {
    await Test.initIndexFilter("posts", ["id"]);
  });

  it("Test post create, update and delete indexing", async () => {
    const originalPost = {
      id: params.id,
      title: `${params.id} title`,
    };

    // Create.
    await Meilisearch.indexPostCreate(originalPost as any, { params: params } as any);
    await Utils.delay(3000);
    let searchResult = await Meilisearch.search("posts", {
      searchOptions: { filter: ["id = " + params.id] },
    });
    // console.log(searchResult);
    expect(searchResult.hits).has.length(1);

    // Update.
    const updatedPost = { ...originalPost, title: "post updated title" };
    Meilisearch.indexPostUpdate(
        {
          before: originalPost as any,
          after: updatedPost as any,
        },
      { params: params } as any
    );
    await Utils.delay(3000);
    searchResult = await Meilisearch.search("posts", {
      searchOptions: { filter: ["id = " + params.id] },
    });
    expect(searchResult.hits).has.length(1);
    expect(searchResult.hits[0].title === updatedPost.title).true;

    // Delete.
    // Expect index is deleted.
    await Meilisearch.deleteIndexedPostDocument({ params: params } as any);
    await Utils.delay(3000);
    searchResult = await Meilisearch.search("posts", {
      searchOptions: { filter: ["id = " + params.id] },
    });
    expect(searchResult.hits).has.length(0);
  });

  it("Test post ignore update", async () => {
    await Meilisearch.indexPostUpdate(
        {
          before: { title: "title-a", content: "a" } as any,
          after: { title: "title-b", content: "b", like: 3 } as any,
        },
      { params: params } as any
    );

    await Utils.delay(1500);

    const createdData = await Meilisearch.search("posts", {
      searchOptions: { filter: ["id=" + params.id] },
    });

    expect(createdData.hits.length).equals(1);

    await Meilisearch.indexPostUpdate(
        {
          before: { title: "title-b", content: "b", like: 3 } as any,
          after: { title: "title-b", content: "b", like: 4 } as any,
        },
      { params: params } as any
    );

    await Utils.delay(2000);

    const updatedData = await Meilisearch.search("posts", {
      searchOptions: { filter: ["id=" + params.id] },
    });

    expect(createdData.hits[0].updatedAt).equal(updatedData.hits[0].updatedAt);

    // Cleanup.
    await Meilisearch.deleteIndexedPostDocument({ params: params } as any);
  });
});
