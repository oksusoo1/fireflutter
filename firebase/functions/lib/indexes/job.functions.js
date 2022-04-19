"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.jobGetProfile = exports.jobUpdateProfile = exports.jobUpdate = exports.jobCreate = void 0;
/**
 * @file job.functions.ts
 *
 * HTTP events for forum functions.
 * (Calling functions via HTTP request, HTTP trigger)
 *
 * CORS
 *  By design, http calls are allowed only from same domain.
 *  If client is from different domain, you need cors.
 *
 * Preflight
 *  By design, only allowed HTTP methods could be made.
 *
 *
 *
 */
const functions = require("firebase-functions");
const job_1 = require("../classes/job");
const ready_1 = require("../ready");
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript
exports.jobCreate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await job_1.Job.create(data));
    });
});
exports.jobUpdate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await job_1.Job.update(data));
    });
});
exports.jobUpdateProfile = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await job_1.Job.updateProfile(data));
    });
});
exports.jobGetProfile = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: false }, async (data) => {
        res.status(200).send(await job_1.Job.getProfile(data.uid));
    });
});
//# sourceMappingURL=job.functions.js.map