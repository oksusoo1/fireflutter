import "mocha";
import { expect } from "chai";
import { Meilisearch } from "../../src/classes/meilisearch";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

new FirebaseAppInitializer();

describe("Meilisearch user document indexing", () => {
  it("Prepares test", async () => {
    Test.initMeiliSearchIndexFilter("users", ["id"]);
  });

  it("Test user create, update and delete indexing", async () => {
    const initialData = {
      // should be `uid` since it replicates the firebase event environment
      // where if a user is created, it will trigger with a UserRecord type payload
      // thus `indexUserCreate()` function will use `data.uid`.
      uid: "uid-" + Utils.getTimestamp(),
    };

    // Create
    await Meilisearch.indexUserCreate(initialData as any);
    await Utils.delay(3000);

    const createdData = await Meilisearch.search("users", { id: initialData.uid });
    expect(createdData.hits.length).to.be.equals(1);

    // Update
    const newFirstName = "firstname update";
    await Meilisearch.indexUserUpdate(
        {
          before: initialData as any,
          after: { firstName: newFirstName } as any,
        },
      { params: initialData } as any
    );
    await Utils.delay(3000);

    const updatedData = await Meilisearch.search("users", { id: initialData.uid });
    expect(updatedData.hits.length).to.be.equals(1);
    expect(updatedData.hits[0].firstName).to.be.equals(newFirstName);

    // Delete
    await Meilisearch.deleteIndexedUserDocument(initialData as any);
    await Utils.delay(3000);
    const deletedSearch = await Meilisearch.search("users", { id: initialData.uid });
    expect(deletedSearch.hits.length).to.be.equals(0);
  });

  it("Test user indexing update ignore", async () => {
    const initialData = {
      uid: "test-uid" + Utils.getTimestamp(),
    };

    await Meilisearch.indexUserUpdate(
        {
          before: initialData as any,
          after: { ...initialData, firstName: "Hello" } as any,
        },
      { params: initialData } as any
    );
    await Utils.delay(3000);

    const createdData = await Meilisearch.search("users", { id: initialData.uid });

    expect(createdData.hits.length).equals(1);

    await Meilisearch.indexUserUpdate(
        {
          before: createdData as any,
          after: { ...createdData, photoUrl: "https://abc.com/def.jpg" } as any,
        },
      { params: initialData } as any
    );
    await Utils.delay(3000);
    const updateAttemptA = await Meilisearch.search("users", { id: initialData.uid });

    expect(updateAttemptA.hits[0].updatedAt).equals(createdData.hits[0].updatedAt);

    await Meilisearch.indexUserUpdate(
        {
          before: createdData as any,
          after: { ...initialData, firstName: "Hello World" } as any,
        },
      { params: initialData } as any
    );
    await Utils.delay(3000);
    const updateAttemptB = await Meilisearch.search("users", { id: initialData.uid });
    expect(updateAttemptB.hits[0].updatedAt).to.be.not.equals(createdData.hits[0].updatedAt);

    // / Cleanup
    await Meilisearch.deleteIndexedUserDocument(initialData as any);
  });
});

