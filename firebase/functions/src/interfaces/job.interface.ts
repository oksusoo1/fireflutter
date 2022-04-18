import * as admin from "firebase-admin";

export interface JobDocument {
  id?: string;
  uid?: string;
  files?: string[];
  companyName: string;
  siNm: string;
  sggNm: string;
  detailAddress: string;
  mobileNumber: string;
  phoneNumber: string;
  email: string;
  aboutUs: string;
  category: string;
  workingDays: number;
  workingHours: number;
  salary: string;
  numberOfHiring: string;
  description: string;
  requirement: string;
  duty: string;
  benefit: string;
  withAccomodation: string;
  status: string;
  createdAt?: admin.firestore.FieldValue;
  updatedAt?: admin.firestore.FieldValue;
}
