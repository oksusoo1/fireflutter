"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const fireflutter_config_1 = require("./fireflutter.config");
admin.initializeApp({
    databaseURL: fireflutter_config_1.config.databaseURL,
    storageBucket: fireflutter_config_1.config.storageBucket,
});
admin.firestore().settings({ ignoreUndefinedProperties: true });
__exportStar(require("./indexes/point.functions"), exports);
__exportStar(require("./indexes/forum.functions"), exports);
__exportStar(require("./indexes/storage.functions"), exports);
__exportStar(require("./indexes/meilisearch.functions"), exports);
__exportStar(require("./indexes/messaging.functions"), exports);
__exportStar(require("./indexes/admin.functions"), exports);
__exportStar(require("./indexes/quiz.functions"), exports);
__exportStar(require("./indexes/basic.functions"), exports);
__exportStar(require("./indexes/job.functions"), exports);
__exportStar(require("./indexes/user.functions"), exports);
//# sourceMappingURL=index.js.map