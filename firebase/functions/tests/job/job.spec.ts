import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";
import { Job } from "../../src/classes/job";
import {
  ERROR_EMPTY_COMPANY_NAME,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_PROVINCE,
  ERROR_JOB_ALREADY_CREATED,
  ERROR_JOB_NOT_EXIST,
  ERROR_LACK_OF_POINT,
  ERROR_NOT_YOUR_JOB,
} from "../../src/defines";
import { Point } from "../../src/classes/point";
import { ExtraReason } from "../../src/interfaces/point.interface";

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
    try {
      await Job.create({ uid: "Not-existing-uid-job-123", companyName: "abc", siNm: "Seoul" });
    } catch (e) {
      expect(e).equals(ERROR_LACK_OF_POINT);
    }

    const user = await Test.createUser();
    await Utils.delay(200);

    await Point.extraPoint(user.id, 100000, "test");
    const job = await Job.create({ uid: user.id, companyName: "abc", siNm: "Seoul" });
    expect(job).to.be.an("object").to.have.property("companyName").equals("abc");

    const registrationPoint = await Point.getRegistrationPoint(user.id);
    const afterPoint = await Point.current(user.id);
    console.log(
        `expect(100000 + ${registrationPoint} - ${Job.pointDeductionForCreation}).equals(${afterPoint});`
    );

    expect(100000 + registrationPoint - Job.pointDeductionForCreation).equals(afterPoint);

    const lastExtra = await Point.getLastExtraPointEvent(user.id);
    expect(lastExtra!.reason).equals(ExtraReason.jobCreate);
  });

  it("Update fail - wrong uid - not your job", async () => {
    const user = await Test.createUser();
    await Point.extraPoint(user.id, 100000, "test");
    const job = await Job.create({ uid: user.id, companyName: "abc", siNm: "Seoul" });
    try {
      await Job.update({ id: job.id, uid: "userB" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_JOB);
    }
  });

  it("Update success", async () => {
    const user = await Test.createUser();
    await Point.extraPoint(user.id, 100000, "test");
    const job = await Job.create({ uid: user.id, companyName: "abc", siNm: "Seoul" });
    const updated = await Job.update({ id: job.id, uid: user.id, companyName: "def" });
    expect(job.id).equals(updated.id);
    expect(updated.companyName).equals("def");
  });

  it("Get a job from Uid", async () => {
    // failure test
    const job = await Job.getJobFromUid("wrong-uid----non-exists-123");
    expect(job).to.be.null;

    // success test

    const user = await Test.createUser();
    await Point.extraPoint(user.id, 100000, "test");
    const created = await Job.create({ uid: user.id, companyName: "abc", siNm: "Seoul" });
    const got = await Job.getJobFromUid(created.uid);
    expect(got!.uid).equals(user.id);
  });

  it("Can't create two jobs", async () => {
    const user = await Test.createUser();
    await Point.extraPoint(user.id, 100000, "test");

    // Create a job
    await Job.create({ uid: user.id, companyName: "abc", siNm: "Seoul" });

    // Create second job
    try {
      await Job.create({ uid: user.id, companyName: "abc", siNm: "Seoul" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_JOB_ALREADY_CREATED);
    }
  });
});
