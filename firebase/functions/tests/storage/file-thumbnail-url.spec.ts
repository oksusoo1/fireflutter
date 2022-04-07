// 0198f620-b642-4e6e-a9a9-ba7a393ebfbe.jpg

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Storage } from "../../src/classes/storage";

new FirebaseAppInitializer();

describe("Storage test", () => {
  it("File from url", async () => {
    const originalUrl =
      "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads/0198f620-b642-4e6e-a9a9-ba7a393ebfbe.jpg?alt=media&token=68bbe590-4171-461f-9c0c-d7e7c3e48701";

    const thumbnailUrl =
      "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads/0198f620-b642-4e6e-a9a9-ba7a393ebfbe_200x200.webp?alt=media";

    const thumbUrl = Storage.getThumbnailUrl(originalUrl);
    expect(thumbUrl).to.be.equals(thumbnailUrl);

    let isImageUrl = Storage.isImageUrl(originalUrl);
    expect(isImageUrl).true;

    isImageUrl = Storage.isImageUrl(thumbnailUrl);
    expect(isImageUrl).false;
  });
});
