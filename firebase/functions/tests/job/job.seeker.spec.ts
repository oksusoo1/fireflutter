import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

// import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";
import { Job } from "../../src/classes/job";

new FirebaseAppInitializer();

describe("Job seeker test", () => {
  it("Create job profile", async () => {
    // Create for the first time.
    const uid = "job-seeker-uid-" + Utils.getTimestamp();
    const created = await Job.updateProfile({ uid: uid, skills: "sing" });
    expect(created).to.be.an("object");
    // console.log(created);

    // Second update will be update only.
    const updated = await Job.updateProfile({ uid: uid, skills: "song" });
    expect(updated).to.have.property("id").equals(uid);
    expect(updated).to.be.an("object").to.have.property("skills").equals("song");
    expect(created.createdAt._nanoseconds).equals(updated.createdAt._nanoseconds);
    expect(created.updatedAt._nanoseconds).not.equals(updated.updatedAt._nanoseconds);

    // / Get the profile
    const got = await Job.getProfile(uid);
    expect(got).to.have.property("id").equals(uid);

    // console.log(got);
  });
});
