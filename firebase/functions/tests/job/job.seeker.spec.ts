import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";
import { Job } from "../../src/classes/job";
import { JobDocument } from "../../src/interfaces/job.interface";

new FirebaseAppInitializer();

const jobDetails: JobDocument = {
  mobileNumber: "+1111111111",
  phoneNumber: "(202) 123 4567",
  email: "company@email.com",
  aboutUs: "Company about us.",
  category: "testCatJob",
  workingDays: 1,
  workingHours: 1,
  salary: "100k",
  numberOfHiring: "3",
  description: "Job description",
  requirements: "Job requirements",
  duties: "Job duties",
  benefits: "Job benefits",
  withAccomodation: "N",
} as any;

describe("Job seeker test", () => {
  it("Create job profile", async () => {
    const profile = await Job.updateProfile({ uid: "abc" });
    expect(profile).to.be.an("object");
    console.log(profile);
  });
});
