import * as admin from "firebase-admin";
import {
  ERROR_EMPTY_COMPANY_NAME,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_PROVINCE,
  ERROR_JOB_ALREADY_CREATED,
  ERROR_JOB_NOT_EXIST,
  ERROR_LACK_OF_POINT,
  ERROR_NOT_YOUR_JOB,
} from "../defines";
import { ExtraReason } from "../interfaces/point.interface";
import { Point } from "./point";

interface JobDocument {
  id: string;
  uid: string;
  companyName: string;
  files: string[];
}

export class Job {
  static pointDeductionForCreation = 1200;
  /**
   * Creates a job
   * @param data data to create a job opening
   * @returns document data
   */
  static async create(data: any): Promise<JobDocument> {
    /** Check input */
    if (typeof data.companyName === "undefined") {
      throw ERROR_EMPTY_COMPANY_NAME;
    }
    if (typeof data.siNm === "undefined") {
      throw ERROR_EMPTY_PROVINCE;
    }

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
    if (!data.id) throw ERROR_EMPTY_ID;
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
    const snapshot = await admin
        .firestore()
        .collection("jobs")
        .where("uid", "==", uid)
        .limit(1)
        .get();
    if (snapshot.size > 0) {
      return snapshot.docs[0].data() as JobDocument;
    } else {
      return null;
    }
  }
}
