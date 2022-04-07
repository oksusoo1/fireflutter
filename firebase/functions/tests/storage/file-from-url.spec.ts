// 0198f620-b642-4e6e-a9a9-ba7a393ebfbe.jpg

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Storage } from "../../src/classes/storage";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Storage test", () => {
  it("File ref from url/path", async () => {
    // upload a file
    const filename = "uploads/delete-test-" + Utils.getTimestamp();
    const file = await Storage.upload("./tests/storage/test.jpg", filename + ".jpg");
    await Utils.delay(2000);
    const thumb = Storage.getRefFromPath(filename + "_200x200.webp");

    const existingFileUrl = file.publicUrl();

    // org file
    const fileA = Storage.getRefFromUrl(existingFileUrl);
    const isExistsA = await fileA.exists();
    expect(isExistsA[0]).true;
    // thumb file
    const thumbExists = await thumb.exists();
    expect(thumbExists[0]).true;

    // does not exist
    const fileB = Storage.getRefFromUrl("not_existing_file.jpg");
    const isExistsB = await fileB.exists();
    expect(isExistsB[0]).false;
  });
});
