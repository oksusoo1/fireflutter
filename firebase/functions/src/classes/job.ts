import * as admin from "firebase-admin";
import {
  ERROR_EMPTY_COMPANY_ABOUT_US,
  ERROR_EMPTY_COMPANY_EMAIL_ADDRESS,
  ERROR_EMPTY_COMPANY_MOBILE_NUMBER,
  ERROR_EMPTY_COMPANY_NAME,
  ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER,
  ERROR_EMPTY_COMPANY_DETAIL_ADDRESS,
  ERROR_EMPTY_ID,
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
  ERROR_EMPTY_PROVINCE,
  ERROR_JOB_ALREADY_CREATED,
  ERROR_JOB_NOT_EXIST,
  ERROR_LACK_OF_POINT,
  ERROR_NOT_YOUR_JOB,
  ERROR_WRONG_JOB_ACCOMODATION_VALUE,
} from "../defines";
import { JobDocument } from "../interfaces/job.interface";
import { ExtraReason } from "../interfaces/point.interface";
import { Point } from "./point";

export class Job {
  static pointDeductionForCreation = 1200;
  /**
   * Creates a job
   * @param data data to create a job opening
   * @returns document data
   */
  static async create(data: any): Promise<JobDocument> {
    /** Check input */

    this.isInputDataComplete(data);

    // Check if the user already create job opening before.
    const previousJob = await this.getJobFromUid(data.uid);
    if (previousJob) {
      throw ERROR_JOB_ALREADY_CREATED;
    }

    // Check if the user has enough point
    const currentPoint = await Point.current(data.uid);
    if (currentPoint < this.pointDeductionForCreation) {
      throw ERROR_LACK_OF_POINT;
    }

    /** End of input check */

    if (typeof data.files === void 0) data.files = [];
    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    data.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    const ref = await admin.firestore().collection("jobs").add(data);

    // Deduct user point
    await Point.extraPoint(data.uid, -this.pointDeductionForCreation, ExtraReason.jobCreate);

    return this.get(ref.id);
  }

  static async update(data: any): Promise<JobDocument> {
    // check if Job ID is present.
    if (!data.id) throw ERROR_EMPTY_ID;

    // check if data is complete and correct.
    this.isInputDataComplete(data);

    const job = await this.get(data.id);
    if (job === null) throw ERROR_JOB_NOT_EXIST;
    if (job.uid !== data.uid) throw ERROR_NOT_YOUR_JOB;

    const id = data.id;
    delete data.id;

    // updatedAt
    data.updatedAt = admin.firestore.FieldValue.serverTimestamp();

    await admin.firestore().collection("jobs").doc(id).update(data);
    return this.get(id);
  }

  static async get(id: string): Promise<JobDocument> {
    if (typeof id === void 0 || id.trim() === "") throw ERROR_EMPTY_ID;
    const ref = admin.firestore().collection("jobs").doc(id);
    // return the document object of newly created post.
    const snapshot = await ref.get();
    if (snapshot.exists === false) throw ERROR_JOB_NOT_EXIST;
    // Post create success
    const job = snapshot.data() as any;
    job.id = ref.id;

    return job;
  }

  /**
   * Returns a job from the user.
   *
   * @param uid user uid
   * @usage Use this to get the user's previous job or to check if the user has already posted a job openning.
   * @note User can only create one job. See readme for details.
   */
  static async getJobFromUid(uid: string): Promise<JobDocument | null> {
    const snapshot = await admin.firestore().collection("jobs").where("uid", "==", uid).limit(1).get();
    if (snapshot.size > 0) {
      return snapshot.docs[0].data() as JobDocument;
    } else {
      return null;
    }
  }

  /**
   * Checks if the job post data is complete and correct.
   *
   * @param data job data
   * @returns true if complete. throws an error if not.
   */
  static isInputDataComplete(data: JobDocument): boolean {
    // company name
    if (typeof data.companyName === "undefined" || data.companyName.trim() == "") {
      throw ERROR_EMPTY_COMPANY_NAME;
    }

    // Address
    //  province - siNm
    //  todo: sggNm
    if (typeof data.siNm === "undefined" || data.siNm.trim() == "") {
      throw ERROR_EMPTY_PROVINCE;
    }
    
    if (typeof data.detailAddress === "undefined" || data.detailAddress.trim() == "") {
      throw ERROR_EMPTY_COMPANY_DETAIL_ADDRESS;
    }

    // Mobile number
    if (typeof data.mobileNumber === "undefined" || data.mobileNumber.trim() == "") {
      throw ERROR_EMPTY_COMPANY_MOBILE_NUMBER;
    }
    // Office number
    if (typeof data.phoneNumber === "undefined" || data.phoneNumber.trim() == "") {
      throw ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER;
    }
    // Email address number
    //  todo: validate email format.
    if (typeof data.email === "undefined" || data.email.trim() == "") {
      throw ERROR_EMPTY_COMPANY_EMAIL_ADDRESS;
    }
    // About us
    if (typeof data.aboutUs === "undefined" || data.aboutUs.trim() == "") {
      throw ERROR_EMPTY_COMPANY_ABOUT_US;
    }
    // Job category
    if (typeof data.category === "undefined" || data.category.trim() == "") {
      throw ERROR_EMPTY_JOB_CATEGORY;
    }
    // Working days
    // Working hours
    //  - undefined or value less than 0 should error
    if (typeof data.workingDays === "undefined" || data.workingDays < 0) {
      throw ERROR_EMPTY_JOB_WORKING_DAYS;
    }
    if (typeof data.workingHours === "undefined" || data.workingHours < 0) {
      throw ERROR_EMPTY_JOB_WORKING_HOURS;
    }
    // Salary
    if (typeof data.salary === "undefined" || data.salary.trim() == "") {
      throw ERROR_EMPTY_JOB_SALARY;
    }
    // Number of hiring
    if (typeof data.numberOfHiring === "undefined" || data.numberOfHiring.trim() == "") {
      throw ERROR_EMPTY_JOB_NUMBER_OF_HIRING;
    }
    // Job Description
    if (typeof data.description === "undefined" || data.description.trim() == "") {
      throw ERROR_EMPTY_JOB_DESCRIPTION;
    }
    // Requirements
    if (typeof data.requirement === "undefined" || data.requirement.trim() == "") {
      throw ERROR_EMPTY_JOB_REQUIREMENT;
    }
    // Duties
    if (typeof data.duty === "undefined" || data.duty.trim() == "") {
      throw ERROR_EMPTY_JOB_DUTY;
    }
    // Benefits
    if (typeof data.benefit === "undefined" || data.benefit.trim() == "") {
      throw ERROR_EMPTY_JOB_BENEFIT;
    }
    // Accomodation
    if (typeof data.withAccomodation === "undefined" || data.withAccomodation.trim() == "") {
      throw ERROR_EMPTY_JOB_ACCOMODATION;
    }
    //  - value other than "Y" or "N" should error.
    if (data.withAccomodation.trim() != ("N" || "Y")) {
      throw ERROR_WRONG_JOB_ACCOMODATION_VALUE;
    }

    return true;
  }
}
