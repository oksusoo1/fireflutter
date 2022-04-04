"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Utils = void 0;
/**
 * @file utils.ts
 */
class Utils {
    /**
     * Returns unix timestamp
     *
     * @return int unix timestamp
     */
    static getTimestamp(servertime) {
        if (servertime) {
            const d = servertime.toDate();
            return Math.round(d.getTime() / 1000);
        }
        else {
            return Math.round(new Date().getTime() / 1000);
        }
    }
    /**
     *
     * @param min
     * @param max
     * @returns
     */
    static getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    /**
     * Wait for milliseconds.
     *
     * @param ms milliseconds
     * @return Promise
     *
     * @example
     *  await Utils.delay(3000);
     */
    static async delay(ms) {
        return new Promise((res) => {
            setTimeout(res, ms);
        });
    }
    /**
     * Convert html entities into code.
     *
     * @param content string with HTML string.
     * @return string without html tags.
     */
    static removeHtmlTags(content) {
        if (content) {
            return content.replace(/<[^>]+>/g, "");
        }
        else {
            return content;
        }
    }
    /**
     * Convert html entities into code.
     *
     * @param {*} text HTML string
     */
    static decodeHTMLEntities(text) {
        const entities = {
            amp: "&",
            apos: "'",
            "#x27": "'",
            "#x2F": "/",
            "#39": "'",
            "#47": "/",
            lt: "<",
            gt: ">",
            nbsp: " ",
            quot: "\"",
            bull: "•",
        };
        return text.replace(/&([^;]+);/gm, function (match, entity) {
            return entities[entity] || match;
        });
    }
    /**
     * Divide an array into many
     *
     * @param {*} arr array
     * @param {*} chunkSize chunk size
     */
    static chunk(arr, chunkSize) {
        if (chunkSize <= 0)
            return []; // don't throw here since it will not be catched.
        const chunks = [];
        for (let i = 0, len = arr.length; i < len; i += chunkSize) {
            chunks.push(arr.slice(i, i + chunkSize));
        }
        return chunks;
    }
}
exports.Utils = Utils;
//# sourceMappingURL=utils.js.map