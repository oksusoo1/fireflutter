export class Utils {
  /**
   * Returns unix timestamp
   *
   * @return int unix timestamp
   */
  static getTimestamp(servertime?: any) {
    if (servertime) {
      const d = servertime.toDate();
      return Math.round(d.getTime() / 1000);
    } else {
      return Math.round(new Date().getTime() / 1000);
    }
  }

  static getRandomInt(min: number, max: number) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
  /**
   * Wait for milliseconds.
   *
   * @param ms milliseconds
   * @returns Promise
   *
   * @example
   *  await Utils.delay(3000);
   */
  static async delay(ms: number) {
    return new Promise((res) => {
      setTimeout(res, ms);
    });
  }

  /**
   * Divide an array into many
   *
   * @param {*} arr array
   * @param {*} chunkSize chunk size
   */
  static chunk(arr: Array<any>, chunkSize: number) {
    if (chunkSize <= 0) return []; // don't throw here since it will not be catched.
    const chunks = [];
    for (let i = 0, len = arr.length; i < len; i += chunkSize) {
      chunks.push(arr.slice(i, i + chunkSize));
    }
    return chunks;
  }
}
