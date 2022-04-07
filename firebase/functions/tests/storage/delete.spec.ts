import "mocha";
import { expect } from "chai";
import * as admin from "firebase-admin";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Storage } from "../../src/classes/storage";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

let url = "";

describe("Storage file delete test", () => {
  it("Upload a file to test with thumbnail", async () => {
    const bucket = admin.storage().bucket();
    const filename = "uploads/test-" + Utils.getTimestamp();
    const destination = filename + ".jpg";
    const res = await bucket.upload("./tests/storage/test.jpg", { destination: destination });

    const org = res[0];
    const thumb = Storage.getRefFromPath(filename + "_200x200.webp");

    expect((await org.exists())[0]).true;

    url = org.publicUrl();

    // Wait for thumbnail to be generated
    await Utils.delay(2000);
    expect((await thumb.exists())[0]).true;
  });

  it("Delete image and its thumbnail image", async () => {
    const file = Storage.getRefFromUrl(url);
    const re = await Storage.deleteFileFromUrl(url);
    expect(re).true;
    expect((await file.exists())[0]).false;
  });
});
