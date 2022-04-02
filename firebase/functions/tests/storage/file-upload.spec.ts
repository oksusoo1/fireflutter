import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Storage } from "../../src/classes/storage";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Storage test", () => {
  it("File upload", async () => {
    const randomId = "id-" + Utils.getTimestamp();
    await Storage.updateFileParentId(randomId, {
      title: "title of file upload test post",
      files: [
        "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads%2F525de0e1-7762-4c25-8bcc-bb361b565deb.jpg?alt=media&token=e7132bce-37e5-43d5-b63e-abcaac18e290",
        "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads%2F64b1f9be-f699-451f-b5f6-378a8b8999e7.jpg?alt=media&token=4b5bd88e-8dae-4e6b-a379-9e970b64541c",
      ],
    });

    const metadata = await Storage.getMetadataFromUrl(
        "https://firebasestorage.googleapis.com/v0/b/withcenter-test-project.appspot.com/o/uploads%2F525de0e1-7762-4c25-8bcc-bb361b565deb.jpg?alt=media&token=e7132bce-37e5-43d5-b63e-abcaac18e290"
    );

    expect(metadata[0].metadata["id"]).equals(randomId);
  });
});
