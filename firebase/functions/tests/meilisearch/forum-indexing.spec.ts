import "mocha";
import { expect } from "chai";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";
import { Meilisearch } from "../../src/classes/meilisearch";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

describe("Meilisearch forum document indexing", () => {
  const timestamp = Utils.getTimestamp();
  // console.log("timestamp :", timestamp);

  it("Prepares test", async () => {
    await Test.initMeiliSearchIndexFilter("posts-and-comments", ["id"]);
  });

  it("Tests simple forum document indexing and deleting.", async () => {
    const testPost = {
      id: `post-id-${timestamp}`,
      title: "some title",
      content: "some content",
    };

    // Indexing
    await Meilisearch.indexForumDocument(testPost);
    await Utils.delay(3000);

    // Search if the post is indexed.
    // It should exactly contain 1 document, since it is filtered out.
    let searchResult = await Meilisearch.search("posts-and-comments", { id: testPost.id });
    // console.log(searchResult);
    expect(searchResult.hits).has.length(1);

    // Deleting
    await Meilisearch.deleteIndexedForumDocument({ params: { id: testPost.id } } as any);
    await Utils.delay(3000);

    // Search
    // It should not contain a document since it is should be deleted..
    searchResult = await Meilisearch.search("posts-and-comments", { id: testPost.id });
    expect(searchResult.hits).has.length(0);
  });
});

