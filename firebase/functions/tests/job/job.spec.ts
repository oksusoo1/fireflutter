import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";
import { Job } from "../../src/classes/job";
import {
  ERROR_EMPTY_COMPANY_NAME,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_PROVINCE,
  ERROR_JOB_NOT_EXIST,
  ERROR_NOT_YOUR_JOB,
} from "../../src/defines";

new FirebaseAppInitializer();

describe("Job test", () => {
  it("Get fail - ERROR_EMPTY_ID", async () => {
    try {
      await Job.get("");
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_ID);
    }
  });
  it("Get fail - ERROR_JOB_NOT_EXIST", async () => {
    try {
      await Job.get("dafadfsadfs");
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_JOB_NOT_EXIST);
    }
  });

  it("Create fail - ERROR_EMPTY_COMPANY_NAME", async () => {
    try {
      await Job.create({});
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_COMPANY_NAME);
    }
  });
  it("Create fail - ERROR_EMPTY_PROVINCE", async () => {
    try {
      await Job.create({ companyName: "abc" });
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_PROVINCE);
    }
  });
  it("Create success", async () => {
    const job = await Job.create({ companyName: "abc", siNm: "Seoul" });
    expect(job).to.be.an("object").to.have.property("companyName").equals("abc");
  });
  it("Update fail - wrong uid - not your job", async () => {
    const job = await Job.create({ uid: "userA", companyName: "abc", siNm: "Seoul" });
    try {
      await Job.update({ id: job.id, uid: "userB" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_JOB);
    }
  });
  it("Update success", async () => {
    const job = await Job.create({ uid: "userA", companyName: "abc", siNm: "Seoul" });
    const updated = await Job.update({ id: job.id, uid: "userA", companyName: "def" });
    expect(job.id).equals(updated.id);
    expect(updated.companyName).equals("def");
  });
});
