import "mocha";
import { expect } from "chai";
import { MeiliSearch } from "meilisearch";

import { MeilisearchIndex } from "../../src/lib/meilisearchIndex";
import { Utils } from "../../src/lib/utils";

const client = new MeiliSearch({ 
  host: "http://wonderfulkorea.kr:7700",
});

describe("Meilisearch forum document indexing", () => {
  it("simple forum document indexing and deleting test", async () => {
    const timestamp = new Date().getTime().toString();
    console.log("timestamp :", timestamp);

    const testPost = MeilisearchIndex.createTestPostDocument({
      id: "postId-" + timestamp,
    });

    /// Indexing
    await MeilisearchIndex.indexForumDocument(testPost);
    await Utils.delay(3000);

    // Search if the post is indexed.
    let searchResult = await client.index("posts-and-comments").search("", { filter: ["id = " + testPost.id] });
    // It should exactly contain 1 document, since it is filtered out.
    // console.log(searchResult);
    expect(searchResult.hits).has.length(1);

    /// Deleting
    await MeilisearchIndex.deleteIndexedForumDocument(testPost.id);
    await Utils.delay(3000);

    // Search
    searchResult = await client.index("posts-and-comments").search("", { filter: ["id = " + testPost.id] });
    // It should not contain a document since it is should be deleted..
    expect(searchResult.hits).has.length(0);
  });
});
