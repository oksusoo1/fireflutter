import "mocha";
import { expect } from "chai";
import { Meilisearch } from "../../src/classes/meilisearch";
import { Utils } from "../../src/classes/utils";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

async function initIndexFilter(index: string) {
  const indexFilters = await Meilisearch.client.index(index).getFilterableAttributes();

  if (!indexFilters.includes("id")) {
    indexFilters.push("id");
    await Meilisearch.client.index(index).updateFilterableAttributes(indexFilters);
  }
}

describe("Meilisearch forum document indexing", () => {
  const timestamp = Utils.getTimestamp();
  console.log("timestamp :", timestamp);

  it("Prepares test", async () => {
    await initIndexFilter("posts-and-comments");
  });

  it("Tests simple forum document indexing and deleting.", async () => {
    const testPost = {
      id: `post-id-${timestamp}`,
      title: "some title",
      content: "some content",
    }

    // Indexing
    await Meilisearch.indexForumDocument(testPost);
    await Utils.delay(3000);

    // Search if the post is indexed.
    // It should exactly contain 1 document, since it is filtered out.
    let searchResult = await Meilisearch.search("posts-and-comments", {
      searchOptions: { filter: ["id = " + testPost.id] },
    });
    // console.log(searchResult);
    expect(searchResult.hits).has.length(1);

    // Deleting
    await Meilisearch.deleteIndexedForumDocument({ params: { id: testPost.id }} as any);
    await Utils.delay(3000);

    // Search
    // It should not contain a document since it is should be deleted..
    searchResult = await Meilisearch.search("posts-and-comments", {
      searchOptions: { filter: ["id = " + testPost.id] },
    });
    expect(searchResult.hits).has.length(0);
  });
});
