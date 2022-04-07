// 0198f620-b642-4e6e-a9a9-ba7a393ebfbe.jpg

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Storage } from "../../src/classes/storage";

new FirebaseAppInitializer();

describe("Storage test", () => {
  it("File from url", async () => {
    const existingFileUrl =
      "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads%2F0198f620-b642-4e6e-a9a9-ba7a393ebfbe.jpg?alt=media&token=68bbe590-4171-461f-9c0c-d7e7c3e48701";

    const fileA = Storage.getFileRefFromUrl(existingFileUrl);
    const isExistsA = await fileA.exists();
    console.log(isExistsA[0]);
    expect(isExistsA[0]).true;

    const fileB = Storage.getFileRefFromUrl("not_existing_file.jpg");
    const isExistsB = await fileB.exists();
    expect(isExistsB[0]).false;
  });
});
