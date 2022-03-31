import "mocha";
import { expect } from "chai";
import { MeiliSearch } from "meilisearch";

import { MeilisearchIndex } from "../../src/classes/meilisearch-index";
import { Utils } from "../../src/classes/utils";

const client = new MeiliSearch({
  host: "http://wonderfulkorea.kr:7700",
});

describe("Meilisearch forum document indexing", () => {
  it("prepares test", async () => {
    const indexFilters = await client.index("posts-and-comments").getFilterableAttributes();

    console.log("Post filterables: ", indexFilters);
    if (!indexFilters.includes("id")) {
      indexFilters.push("id");
      console.log("Updating post filterables: ", indexFilters);
      await client.index("posts").updateFilterableAttributes(indexFilters);
    }
  });

  it("simple forum document indexing and deleting test", async () => {
    const timestamp = new Date().getTime().toString();
    console.log("timestamp :", timestamp);

    const testPost = MeilisearchIndex.createTestPostDocument({
      id: "postId-" + timestamp,
    });

    // / Indexing
    await MeilisearchIndex.indexForumDocument(testPost);
    await Utils.delay(3000);

    // Search if the post is indexed.
    let searchResult = await client
      .index("posts-and-comments")
      .search("", { filter: ["id = " + testPost.id] });
    // It should exactly contain 1 document, since it is filtered out.
    // console.log(searchResult);
    expect(searchResult.hits).has.length(1);

    // / Deleting
    await MeilisearchIndex.deleteIndexedForumDocument(testPost.id);
    await Utils.delay(3000);

    // Search
    searchResult = await client
      .index("posts-and-comments")
      .search("", { filter: ["id = " + testPost.id] });
    // It should not contain a document since it is should be deleted..
    expect(searchResult.hits).has.length(0);
  });
});
