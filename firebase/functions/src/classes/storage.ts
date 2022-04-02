import * as admin from "firebase-admin";
export class Storage {
  /**
   * Update post or comment id on the file meta.
   *
   * Note, for a test, id (post id or comment id) does not have to be exists.
   *    - But, the files(url) must exist in storage.
   *
   * @param id  post id or comment id.
   * @param data document data
   * @returns
   */
  static async updateFileParentId(id: string, data: any) {
    if (!data || !data.files || !data.files.length) {
      return;
    }
    const bucket = admin.storage().bucket();
    for (const url of data.files) {
      const f = bucket.file(this.getFilePathFromUrl(url));
      if (await f.exists()) {
        await f.setMetadata({
          metadata: {
            id: id,
          },
        });
      } else {
        console.log("ERROR -> file url not exists: ", url);
      }
    }
  }

  /**
   * Returns (first part) of metadata.
   *
   * The raw(whole) metadata looks a bit complicated and the first element of the metadata has important information.
   *
   * @param url url of an uploaded file(or image)
   * @returns first part of metadata. It has `metadata` property inside along with link, name, content type, etc.
   *
   * @example
   *  const metadata = await Storage.getMetadataFromUrl(
   *   "https://firebasestorage.googleapis.com/v0/b/withcenter-test-projec...25-deb.jpg?alt=media&token=e713c18e290"
   *  );
   *  console.log(metadata[0]);
   *  console.log(metadata[0].metadata);
   */
  static getMetadataFromUrl(url: string) {
    const file = admin.storage().bucket().file(this.getFilePathFromUrl(url));
    return file.getMetadata();
  }

  /**
   * Returns the storage path of the uploaded file.
   *
   * @param {*} url url of the uploaded file
   * @returns path of the uploaded file
   *
   * @usage Use this to get file from url.
   *
   * @example
   * admin.storage().bucket().file( getFilePathFromUrl('https://...'))
   */
  static getFilePathFromUrl(url: string) {
    const token = url.split("?");
    const parts = token[0].split("/");
    return parts[parts.length - 1].replaceAll("%2F", "/");
  }
}
