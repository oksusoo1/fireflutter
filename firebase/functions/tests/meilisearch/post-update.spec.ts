import "mocha";
import { expect } from "chai";
import { Meilisearch } from "../../src/classes/meilisearch";
import { Utils } from "../../src/classes/utils";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

// add filters for id to be filterable on meilisearch,
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
    await initIndexFilter("posts");
  });

  it("Test post ignore update", async () => {
    const id = "post-id-a-1" + Utils.getTimestamp();
    await Meilisearch.indexPostUpdate(
      {
        before: { title: "title-a", content: "a" } as any,
        after: { title: "title-b", content: "b", like: 3 } as any,
      },
      { params: { id: id } }
    );

    await Utils.delay(1500);

    const createdData = await Meilisearch.search("posts", {
      searchOptions: { filter: ["id=" + id] },
    });

    expect(createdData.hits.length).equals(1);

    await Meilisearch.indexPostUpdate(
      {
        before: { title: "title-b", content: "b", like: 3 } as any,
        after: { title: "title-b", content: "b", like: 4 } as any,
      },
      { params: { id: id } }
    );

    await Utils.delay(2000);

    const updatedData = await Meilisearch.search("posts", {
      searchOptions: { filter: ["id=" + id] },
    });

    expect(createdData.hits[0].updatedAt).equal(updatedData.hits[0].updatedAt);
  });
});
