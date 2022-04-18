import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { Job } from "../../src/classes/job";
import { JobDocument } from "../../src/interfaces/job.interface";
import {
  ERROR_EMPTY_COMPANY_ABOUT_US,
  ERROR_EMPTY_COMPANY_EMAIL_ADDRESS,
  ERROR_EMPTY_COMPANY_MOBILE_NUMBER,
  ERROR_EMPTY_COMPANY_NAME,
  ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER,
  ERROR_EMPTY_COMPANY_DETAIL_ADDRESS,
  ERROR_EMPTY_JOB_ACCOMODATION,
  ERROR_EMPTY_JOB_BENEFIT,
  ERROR_EMPTY_JOB_CATEGORY,
  ERROR_EMPTY_JOB_DESCRIPTION,
  ERROR_EMPTY_JOB_DUTY,
  ERROR_EMPTY_JOB_NUMBER_OF_HIRING,
  ERROR_EMPTY_JOB_REQUIREMENT,
  ERROR_EMPTY_JOB_SALARY,
  ERROR_EMPTY_JOB_WORKING_DAYS,
  ERROR_EMPTY_JOB_WORKING_HOURS,
  ERROR_EMPTY_SINM,
  ERROR_EMPTY_SGGNM,
} from "../../src/defines";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";
import { Point } from "../../src/classes/point";

new FirebaseAppInitializer();

const sampleData: JobDocument = <any>{} as any;

describe("Job input check test", () => {
  it("Create fail - ERROR_EMPTY_COMPANY_NAME", async () => {
    try {
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_COMPANY_NAME);
    }
  });
  it("Create fail - ERROR_EMPTY_SINM", async () => {
    try {
      sampleData.companyName = "abc";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_SINM);
    }
  });
  it("Create fail - ERROR_EMPTY_SGGNM", async () => {
    try {
      sampleData.siNm = "siNm";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_SGGNM);
    }
  });
  it("Create fail - ERROR_EMPTY_COMPANY_DETAIL_ADDRESS", async () => {
    try {
      sampleData.sggNm = "sggNm";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_COMPANY_DETAIL_ADDRESS);
    }
  });
  it("Create fail - ERROR_EMPTY_COMPANY_MOBILE_NUMBER", async () => {
    try {
      sampleData.detailAddress = "company detailed address";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_COMPANY_MOBILE_NUMBER);
    }
  });
  it("Create fail - ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER", async () => {
    try {
      sampleData.mobileNumber = "0123456";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER);
    }
  });
  it("Create fail - ERROR_EMPTY_COMPANY_EMAIL_ADDRESS", async () => {
    try {
      sampleData.phoneNumber = "01234";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_COMPANY_EMAIL_ADDRESS);
    }
  });
  it("Create fail - ERROR_EMPTY_COMPANY_ABOUT_US", async () => {
    try {
      sampleData.email = "some@email.com";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_COMPANY_ABOUT_US);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_CATEGORY", async () => {
    try {
      sampleData.aboutUs = "about the company";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_CATEGORY);
    }
  });
  // / WORKING DAYS - undefined
  it("Create fail - ERROR_EMPTY_JOB_WORKING_DAYS (undefined)", async () => {
    try {
      sampleData.category = "IT";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_WORKING_DAYS);
    }
  });
  // / WORKING DAYS - -1
  it("Create fail - ERROR_EMPTY_JOB_WORKING_DAYS (-1 as num)", async () => {
    try {
      sampleData.workingDays = -1;
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_WORKING_DAYS);
    }
  });
  // / WORKING DAYS - undefined
  it("Create fail - ERROR_EMPTY_JOB_WORKING_HOURS (undefined)", async () => {
    try {
      sampleData.workingDays = 0;
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_WORKING_HOURS);
    }
  });
  // / WORKING DAYS - -1
  it("Create fail - ERROR_EMPTY_JOB_WORKING_HOURS (-1 as num)", async () => {
    try {
      sampleData.workingHours = -1;
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_WORKING_HOURS);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_SALARY", async () => {
    try {
      sampleData.workingHours = 0;
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_SALARY);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_NUMBER_OF_HIRING", async () => {
    try {
      sampleData.salary = "100K";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_NUMBER_OF_HIRING);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_DESCRIPTION", async () => {
    try {
      sampleData.numberOfHiring = "3";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_DESCRIPTION);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_REQUIREMENTS", async () => {
    try {
      sampleData.description = "this is the job description";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_REQUIREMENT);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_DUTIES", async () => {
    try {
      sampleData.requirement = "Job requirements";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_DUTY);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_BENEFITS", async () => {
    try {
      sampleData.duty = "Some job duties";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_BENEFIT);
    }
  });
  it("Create fail - ERROR_EMPTY_JOB_ACCOMODATION", async () => {
    try {
      sampleData.benefit = "job benefits";
      await Job.create(sampleData);
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_JOB_ACCOMODATION);
    }
  });
  // / Success
  it("Create success", async () => {
    const user = await Test.createUser();
    await Utils.delay(200);

    await Point.extraPoint(user.id, 100000, "test");


    sampleData.withAccomodation = "N";
    sampleData.uid = user.id;
    const job = await Job.create(sampleData);

    expect(job).to.be.an("object").has.property("id");
    expect(job.companyName).equals(sampleData.companyName);
  });
});
