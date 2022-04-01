import "mocha";
import { expect } from "chai";
import { Meilisearch } from "../../src/classes/meilisearch";
import { Utils } from "../../src/classes/utils";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

function createTestForumDocument(data: {
  id: string;
  title?: string;
  content?: string;
}): any {
  return {
    id: data.id,
    title: data.title ?? `${data.id} title`,
    content: data.content ?? `${data.id} content`,
  };
}

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

  it("prepares test", async () => {
    await initIndexFilter("posts-and-comments");
  });

  it("simple forum document indexing and deleting test", async () => {
    const testPost = createTestForumDocument({
      id: "postId-" + timestamp,
    });

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
    await Meilisearch.deleteIndexedForumDocument(testPost.id!);
    await Utils.delay(3000);

    // Search
    // It should not contain a document since it is should be deleted..
    searchResult = await Meilisearch.search("posts-and-comments", {
      searchOptions: { filter: ["id = " + testPost.id] },
    });
    expect(searchResult.hits).has.length(0);
  });
});
