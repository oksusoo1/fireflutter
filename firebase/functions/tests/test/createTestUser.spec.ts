import "mocha";
import { expect } from "chai";

// import { EventName, Point, randomPoint } from "../../src/library/point";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Test } from "../../src/library/test";
import { UserData } from "../../src/interfaces/user.interface";
import { Utils } from "../../src/library/utils";
import { ERROR_USER_EXISTS } from "../../src/defines";

new FirebaseAppInitializer();

describe("User create test", () => {
  it("Create a user", async () => {
    const uid = "uid-" + Utils.getTimestamp();
    const ref = await Test.createTestUser(uid, { middleName: "test-a-yo" });
    expect(ref).to.be.an("object");

    const snapshot = await ref.get();
    expect(snapshot.key).equal(uid);

    const data = snapshot.val() as UserData;
    expect(data).to.be.an("object").to.have.property("middleName").equal("test-a-yo");

    //
    try {
      await Test.createTestUser(uid, { middleName: "test-a-yo" });
      expect.fail("Creating another user with same uid must be failed.");
    } catch (e) {
      expect(e).equal(ERROR_USER_EXISTS);
    }
  });
});
