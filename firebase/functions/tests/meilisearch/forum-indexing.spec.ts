import "mocha";
import { expect } from "chai";
import { Meilisearch } from "../../src/classes/meilisearch";
import { Utils } from "../../src/classes/utils";
import { Ref } from "../../src/classes/ref";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

async function initIndexFilter(index: string) {
  const indexFilters = await Meilisearch.client.index(index).getFilterableAttributes();

  // console.log("Post filterables: ", indexFilters);
  if (!indexFilters.includes("id")) {
    indexFilters.push("id");
    // console.log("Updating post filterables: ", indexFilters);
    await Meilisearch.client.index(index).updateFilterableAttributes(indexFilters);
  }
}

describe("Meilisearch forum document indexing", () => {
  const timestamp = Utils.getTimestamp();
  console.log("timestamp :", timestamp);

  it("prepares test", async () => {
    // await initIndexFilter("posts-and-comments");
    await initIndexFilter("posts");
    // await initIndexFilter("comments");
  });

  it("simple forum document indexing and deleting test", async () => {
    const testPost = Meilisearch.createTestPostDocument({
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

  it("Test post create, update and delete indexing", async () => {
    const postId = "postId-" + timestamp;
    const params = { id: postId };
    const originalPost = Meilisearch.createTestPostDocument(params);

    // Create.
    await Meilisearch.indexPostCreate(originalPost, { params: params });
    await Utils.delay(3000);
    let searchResult = await Meilisearch.search("posts", { searchOptions: { filter: ["id = " + postId] } });
    // console.log(searchResult);
    expect(searchResult.hits).has.length(1);

    // Update.
    const updatedPost = { ...originalPost, title: "post updated title" };
    Meilisearch.indexPostUpdate({ before: originalPost, after: updatedPost }, { params: params });
    await Utils.delay(3000);
    searchResult = await Meilisearch.search("posts", { searchOptions: { filter: ["id = " + postId] } });
    expect(searchResult.hits).has.length(1);
    expect(searchResult.hits[0].title === updatedPost.title).true;

    // Delete.
    // Expect index is deleted.
    await Meilisearch.deleteIndexedPostDocument({ params: params });
    await Utils.delay(3000);
    searchResult = await Meilisearch.search("posts", { searchOptions: { filter: ["id = " + postId] } });
    expect(searchResult.hits).has.length(0);
  });
});
