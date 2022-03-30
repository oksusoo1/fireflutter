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
}
